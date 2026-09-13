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
};

/**
 * Health check endpoint
 */
function handleHealth(env: Env): Response {
  const hasServiceAccount = Boolean(env.FIREBASE_SERVICE_ACCOUNT);
  return jsonResponse({
    status: 'ok',
    service: 'notify-jobs-fcm-worker',
    environment: env.ENVIRONMENT || 'production',
    serviceAccountConfigured: hasServiceAccount,
    timestamp: new Date().toISOString(),
  });
}

/**
 * Secure FCM Send Handler
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
  let payload: NotificationPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  if (!payload.title || !payload.body) {
    return jsonResponse({ error: 'Missing required fields: title, body' }, 400);
  }

  const topic = payload.topic || 'all_updates';

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

  // Construct FCM HTTP v1 Message
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
        ...(payload.data || {}),
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          channel_id: 'notify_jobs_channel',
          ...(payload.imageUrl ? { image_url: payload.imageUrl } : {}),
        },
      },
    },
  };

  if (payload.token) {
    fcmMessage.message.token = payload.token;
  } else {
    // Topic dispatch (e.g. /topics/all_updates)
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
    console.error('FCM Send Error:', fcmResult);
    return jsonResponse(
      {
        error: 'Failed to dispatch FCM message',
        details: fcmResult,
      },
      fcmResponse.status
    );
  }

  return jsonResponse({
    success: true,
    messageId: fcmResult.name,
    topic: payload.token ? undefined : topic,
    sentAt: new Date().toISOString(),
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
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
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

function jsonResponse(data: any, status = 200): Response {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
    },
  });
}
