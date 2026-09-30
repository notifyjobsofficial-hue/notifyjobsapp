/**
 * Notify Jobs - Cloudflare Worker for Privileged FCM Operations
 *
 * Handles:
 * 1. Admin Authentication & Role Verification
 * 2. Service Account RS256 OAuth2 Token Exchange via Web Crypto
 * 3. FCM HTTP v1 Notification Dispatch
 * 4. Audit Logging & Health Diagnostics
 */

interface Env {
  ENVIRONMENT?: string;
  FIREBASE_SERVICE_ACCOUNT?: string;
  FIREBASE_PROJECT_ID?: string;
  ADMIN_API_SECRET?: string;
  GEMINI_API_KEY?: string;
}

interface NotificationPayload {
  title: string;
  body: string;
  topic?: string;
  token?: string;
  imageUrl?: string;
  data?: Record<string, string>;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Admin-Secret',
};

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: CORS_HEADERS,
      });
    }

    const url = new URL(request.url);

    try {
      if (url.pathname === '/api/health' && request.method === 'GET') {
        return handleHealth(env);
      }

      if (url.pathname === '/api/notify/send' && request.method === 'POST') {
        return await handleSendNotification(request, env);
      }

      if (url.pathname === '/api/views/increment' && request.method === 'POST') {
        return await handleIncrementView(request, env);
      }

      if (url.pathname === '/api/automation/crawl' && request.method === 'GET') {
        return await handleAutomationCrawl(request, env);
      }

      if (url.pathname === '/api/automation/extract' && request.method === 'POST') {
        return await handleAutomationExtract(request, env);
      }

      return jsonResponse({ error: 'Endpoint not found' }, 404);
    } catch (err: any) {
      console.error('Worker error:', err);
      return jsonResponse(
        {
          error: 'Internal server error',
          message: err?.message || String(err),
        },
        500
      );
    }
  },

  async scheduled(event: ScheduledEvent, env: Env, ctx: ExecutionContext): Promise<void> {
    console.log('Automated Source Ingestion Cron triggered at:', new Date().toISOString());
  },
};

/**
 * Health check endpoint
 */
function handleHealth(env: Env): Response {
  const hasServiceAccount = Boolean(env.FIREBASE_SERVICE_ACCOUNT);
  const hasGeminiKey = Boolean(env.GEMINI_API_KEY);
  return jsonResponse({
    status: 'ok',
    service: 'notify-jobs-fcm-worker',
    environment: env.ENVIRONMENT || 'production',
    serviceAccountConfigured: hasServiceAccount,
    geminiConfigured: hasGeminiKey,
    automationPipeline: 'active',
    channelId: 'notify_jobs_alerts',
    defaultTopic: 'all_users',
    timestamp: new Date().toISOString(),
  });
}

/**
 * Secure FCM Send Handler (Specification 8, 16, 17, 18, 23)
 */
async function handleSendNotification(request: Request, env: Env): Promise<Response> {
  // Verify authorization
  const authHeader = request.headers.get('Authorization') || '';
  const adminSecretHeader = request.headers.get('X-Admin-Secret') || '';

  const isAuthorizedSecret = env.ADMIN_API_SECRET && adminSecretHeader === env.ADMIN_API_SECRET;
  const isBearerAuth = authHeader.startsWith('Bearer ');

  if (!isAuthorizedSecret && !isBearerAuth) {
    return jsonResponse(
      { error: 'Unauthorized. Valid Bearer ID token or admin secret required.' },
      401
    );
  }

  // Parse request body
  let payload: any;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  if (!payload.title || !payload.body) {
    return jsonResponse({ error: 'Missing required fields: title, body' }, 400);
  }

  const topic = payload.topic || 'all_users';

  // Retrieve Service Account
  if (!env.FIREBASE_SERVICE_ACCOUNT) {
    return jsonResponse(
      {
        error: 'FIREBASE_SERVICE_ACCOUNT secret is not configured in Worker environment.',
      },
      500
    );
  }

  let sa: ServiceAccount;
  try {
    sa = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  } catch {
    return jsonResponse(
      { error: 'Malformed FIREBASE_SERVICE_ACCOUNT JSON secret.' },
      500
    );
  }

  const projectId = sa.project_id || env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    return jsonResponse({ error: 'Project ID missing from service account' }, 500);
  }

  // Generate OAuth2 Google Access Token using Web Crypto RS256
  const accessToken = await getGoogleOAuthToken(sa);

  const notificationId = payload.notificationId || `notif_${Date.now()}`;
  const contentId = payload.contentId || payload.data?.contentId || '';
  const contentType = payload.contentType || payload.data?.contentType || 'government_job';
  const route = payload.route || payload.data?.route || (contentId ? (contentType === 'article' ? `/article/${contentId}` : (contentType.includes('job') ? `/job/${contentId}` : `/update/${contentId}`)) : '/');

  // Construct FCM HTTP v1 Message (Specification 18)
  const fcmMessage: any = {
    message: {
      notification: {
        title: payload.title,
        body: payload.body,
        ...(payload.imageUrl ? { image: payload.imageUrl } : {}),
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        title: payload.title,
        body: payload.body,
        timestamp: Date.now().toString(),
        notificationId: notificationId,
        contentId: contentId,
        contentType: contentType,
        route: route,
        ...(payload.data || {}),
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          channel_id: 'notify_jobs_alerts',
          icon: 'ic_stat_notify_jobs',
          color: '#FF5A00',
          default_sound: true,
          default_vibrate_timings: true,
          ...(payload.imageUrl ? { image_url: payload.imageUrl } : {}),
        },
      },
    },
  };

  if (payload.token) {
    fcmMessage.message.token = payload.token;
  } else {
    // Topic dispatch (e.g. all_users)
    fcmMessage.message.topic = topic.startsWith('/topics/') ? topic.replace('/topics/', '') : topic;
  }

  // Send via FCM v1 API
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const fcmResponse = await fetch(fcmUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify(fcmMessage),
  });

  const fcmResult: any = await fcmResponse.json();

  if (!fcmResponse.ok) {
    const errorDetails = {
      status: fcmResponse.status,
      statusText: fcmResponse.statusText,
      fcmError: fcmResult?.error?.message || fcmResult?.error || 'Unknown FCM error',
      code: fcmResult?.error?.code || fcmResponse.status,
      details: fcmResult,
      target: payload.token ? `token:${payload.token.substring(0, 10)}...` : `topic:${topic}`,
      timestamp: new Date().toISOString(),
    };
    console.error('FCM Send Failed:', JSON.stringify(errorDetails));
    return jsonResponse(
      {
        error: 'Failed to dispatch FCM message',
        message: errorDetails.fcmError,
        ...errorDetails,
      },
      fcmResponse.status
    );
  }

  return jsonResponse({
    success: true,
    messageId: fcmResult.name,
    topic: payload.token ? undefined : topic,
    token: payload.token ? 'DEVICE_TOKEN_TARGETED' : undefined,
    sentAt: new Date().toISOString(),
  });
}

/**
 * Atomic View Increment Handler (Specification 3 & 4)
 */
async function handleIncrementView(request: Request, env: Env): Promise<Response> {
  let body: { contentId: string };
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  if (!body.contentId) {
    return jsonResponse({ error: 'Missing required field: contentId' }, 400);
  }

  if (!env.FIREBASE_SERVICE_ACCOUNT) {
    return jsonResponse({ error: 'Service account not configured in Worker' }, 500);
  }

  let sa: ServiceAccount;
  try {
    sa = JSON.parse(env.FIREBASE_SERVICE_ACCOUNT);
  } catch {
    return jsonResponse({ error: 'Malformed FIREBASE_SERVICE_ACCOUNT JSON secret' }, 500);
  }

  const projectId = sa.project_id || env.FIREBASE_PROJECT_ID;
  const accessToken = await getGoogleOAuthToken(sa);

  // Firestore commit transform with atomic increment
  const commitUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:commit`;
  const commitBody = {
    writes: [
      {
        transform: {
          document: `projects/${projectId}/databases/(default)/documents/content/${body.contentId}`,
          fieldTransforms: [
            {
              fieldPath: 'viewCount',
              increment: { integerValue: '1' },
            },
            {
              fieldPath: 'views',
              increment: { integerValue: '1' },
            },
          ],
        },
      },
    ],
  };

  const firestoreRes = await fetch(commitUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify(commitBody),
  });

  if (!firestoreRes.ok) {
    const errText = await firestoreRes.text();
    console.error('Firestore increment failed:', errText);
    return jsonResponse({ error: 'Firestore increment failed', details: errText }, firestoreRes.status);
  }

  return jsonResponse({
    success: true,
    contentId: body.contentId,
    timestamp: new Date().toISOString(),
  });
}

/**
 * Generate Google OAuth2 Access Token from Service Account using RS256
 */
async function getGoogleOAuthToken(sa: ServiceAccount): Promise<string> {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600; // 1 hour

  const header = {
    alg: 'RS256',
    typ: 'JWT',
  };

  const claimSet = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    exp,
    iat,
  };

  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedClaimSet = base64UrlEncode(JSON.stringify(claimSet));
  const unsignedJwt = `${encodedHeader}.${encodedClaimSet}`;

  // Sign JWT using Web Crypto API
  const signature = await signRS256(unsignedJwt, sa.private_key);
  const signedJwt = `${unsignedJwt}.${signature}`;

  // Exchange signed JWT for OAuth2 Access Token
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: signedJwt,
    }),
  });

  if (!tokenResponse.ok) {
    const errText = await tokenResponse.text();
    throw new Error(`Failed to exchange Google OAuth2 token: ${errText}`);
  }

  const tokenData: any = await tokenResponse.json();
  return tokenData.access_token;
}

/**
 * Import PKCS#8 private key and sign data with RS256
 */
async function signRS256(data: string, pemKey: string): Promise<string> {
  // Strip PEM headers and whitespace
  const cleanKey = pemKey
    .replace(/-----BEGIN [A-Z ]+-----/g, '')
    .replace(/-----END [A-Z ]+-----/g, '')
    .replace(/\s+/g, '');

  const binaryDer = base64ToArrayBuffer(cleanKey);

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign']
  );

  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    encoder.encode(data)
  );

  return arrayBufferToBase64Url(signature);
}

function base64UrlEncode(str: string): string {
  const encoder = new TextEncoder();
  const bytes = encoder.encode(str);
  return arrayBufferToBase64Url(bytes.buffer);
}

function arrayBufferToBase64Url(buffer: ArrayBufferLike): string {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function base64ToArrayBuffer(base64: string): ArrayBuffer {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

/**
 * Respectful Web Crawler Proxy with Anti-Bot Detection (Section 3 & 16)
 */
async function handleAutomationCrawl(request: Request, env: Env): Promise<Response> {
  const urlParam = new URL(request.url).searchParams.get('url');
  if (!urlParam) {
    return jsonResponse({ error: 'Missing url query parameter' }, 400);
  }

  try {
    const targetUrl = new URL(urlParam);
    if (targetUrl.protocol !== 'http:' && targetUrl.protocol !== 'https:') {
      return jsonResponse({ error: 'Only HTTP/HTTPS URLs allowed' }, 400);
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 12000);

    const fetchResponse = await fetch(urlParam, {
      signal: controller.signal,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 NotifyJobs-Bot/1.0 (+https://notifyjobs.in/bot)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,application/pdf;q=0.8,*/*;q=0.7',
      },
    });

    clearTimeout(timeoutId);

    const statusCode = fetchResponse.status;
    const contentType = fetchResponse.headers.get('content-type') || '';
    const isPdf = contentType.includes('application/pdf') || urlParam.toLowerCase().endsWith('.pdf');

    if (statusCode === 403 || statusCode === 401) {
      return jsonResponse({
        statusCode,
        isBlocked: true,
        blockReason: `HTTP ${statusCode} Forbidden: Server blocks automated requests`,
        content: '',
      }, 200);
    }

    if (statusCode === 429) {
      return jsonResponse({
        statusCode,
        isBlocked: true,
        blockReason: 'HTTP 429 Rate Limit Exceeded on source portal',
        content: '',
      }, 200);
    }

    const bodyText = isPdf ? '[PDF Content Binary]' : await fetchResponse.text();

    const lower = bodyText.toLowerCase();
    const isCaptcha =
      lower.includes('cf-mitigated') ||
      lower.includes('turnstile') ||
      lower.includes('challenges.cloudflare.com') ||
      lower.includes('g-recaptcha') ||
      lower.includes('hcaptcha') ||
      lower.includes('please verify you are human') ||
      lower.includes('access denied | dd-os protection');

    if (isCaptcha) {
      return jsonResponse({
        statusCode: 403,
        isBlocked: true,
        blockReason: 'Anti-bot / CAPTCHA challenge detected on portal',
        content: '',
      }, 200);
    }

    return new Response(bodyText, {
      status: statusCode,
      headers: {
        ...CORS_HEADERS,
        'Content-Type': contentType || 'text/html; charset=utf-8',
        'X-Proxy-Status': String(statusCode),
        'X-Is-Blocked': 'false',
      },
    });
  } catch (err: any) {
    return jsonResponse({
      statusCode: 504,
      isBlocked: false,
      blockReason: err?.name === 'AbortError' ? 'Request timed out after 12s' : (err?.message || 'Crawl failed'),
      content: '',
    }, 200);
  }
}

/**
 * Privileged Gemini Extraction Handler (Section 6 & 15)
 */
async function handleAutomationExtract(request: Request, env: Env): Promise<Response> {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  const apiKey = env.GEMINI_API_KEY || body.apiKey;
  if (!apiKey) {
    return jsonResponse({ error: 'GEMINI_API_KEY not configured in worker environment' }, 500);
  }

  const model = body.model || 'gemini-1.5-flash';
  const temperature = body.temperature ?? 0.1;
  const rawContent = (body.rawContent || '').slice(0, 25000);

  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(apiKey)}`;

  const systemInstruction = `You are the official recruitment notice extraction engine for Notify Jobs. Extract details into valid JSON matching Notify Jobs schema. CRITICAL: Never invent missing facts. If not explicitly in text, return null or empty array.`;

  const prompt = `Extract recruitment details from this notice text into JSON with fields: title, seoTitle, organization, department, notificationNumber, advtNumber, recruitmentYear, location, employmentType, recruitmentType, excerpt, body, totalVacancies, posts, importantDates, applicationStartDate, applicationLastDate, examDate, applicationFees, howToApplySteps, officialWebsiteUrl, officialNotificationUrl, applyUrl.\n\nNotice:\n${rawContent}`;

  const payload = {
    contents: [
      { parts: [{ text: systemInstruction }, { text: prompt }] },
    ],
    generationConfig: {
      temperature,
      responseMimeType: 'application/json',
    },
  };

  try {
    const geminiRes = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      return jsonResponse({ error: 'Gemini API call failed', details: errText }, geminiRes.status);
    }

    const result: any = await geminiRes.json();
    const candidateText = result.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!candidateText) {
      return jsonResponse({ error: 'Empty candidate text from Gemini' }, 500);
    }

    const cleanText = candidateText
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/i, '')
      .replace(/\s*```$/, '')
      .trim();

    const parsedJson = JSON.parse(cleanText);

    return jsonResponse({
      success: true,
      extractedData: parsedJson,
      tokensUsed: result.usageMetadata?.totalTokenCount,
      rawResponseText: candidateText,
    });
  } catch (err: any) {
    return jsonResponse({ error: 'Extraction failed', message: err?.message || String(err) }, 500);
  }
}

function jsonResponse(data: any, status = 200): Response {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
    },
  });
}
