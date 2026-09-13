import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DEFAULT_SUPER_ADMIN_EMAIL = 'laurelsformahesh@gmail.com';
const EXPECTED_PROJECT_ID = 'notify-jobs-753b8';

// 1. Locate service account credentials
function locateServiceAccountKey() {
  const candidatePaths = [
    process.env.SERVICE_ACCOUNT_KEY_PATH,
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.resolve(__dirname, 'serviceAccountKey.json'),
    path.resolve(__dirname, '../serviceAccountKey.json'),
    path.resolve(process.cwd(), 'serviceAccountKey.json'),
  ].filter(Boolean);

  for (const p of candidatePaths) {
    if (fs.existsSync(p)) {
      return p;
    }
  }

  // Also check for any firebase-adminsdk*.json in scripts/ or root
  const dirs = [__dirname, path.resolve(__dirname, '..')];
  for (const dir of dirs) {
    if (fs.existsSync(dir)) {
      const files = fs.readdirSync(dir);
      const match = files.find(
        (f) =>
          f.endsWith('.json') &&
          (f.includes('adminsdk') || f.includes('service-account') || f.includes('serviceAccount'))
      );
      if (match) {
        return path.resolve(dir, match);
      }
    }
  }

  return null;
}

async function main() {
  const targetEmail = (process.argv[2] || DEFAULT_SUPER_ADMIN_EMAIL).trim().toLowerCase();

  console.log('\n============================================================');
  console.log('   Notify Jobs: First Super-Admin Bootstrap');
  console.log('============================================================');
  console.log(`Target Email     : ${targetEmail}`);
  console.log(`Expected Project : ${EXPECTED_PROJECT_ID}`);
  console.log('------------------------------------------------------------');

  const keyPath = locateServiceAccountKey();
  if (!keyPath) {
    console.error('\n❌ ERROR: Service account credentials key file not found!\n');
    console.error('To run this bootstrap script securely:');
    console.error('1. Open Firebase Console: https://console.firebase.google.com/');
    console.error(`2. Select project: "${EXPECTED_PROJECT_ID}"`);
    console.error('3. Click the gear icon (Project Settings) -> "Service accounts" tab.');
    console.error('4. Click "Generate new private key" -> confirm "Generate key".');
    console.error('5. Rename the downloaded file to: serviceAccountKey.json');
    console.error(`6. Move it into this folder: ${__dirname}\\serviceAccountKey.json`);
    console.error('   (Note: serviceAccountKey.json is in .gitignore and will never be committed)');
    console.error('7. Re-run: npm run bootstrap\n');
    process.exit(1);
  }

  console.log(`Using credentials : ${keyPath}`);

  let serviceAccount;
  try {
    const raw = fs.readFileSync(keyPath, 'utf8');
    serviceAccount = JSON.parse(raw);
  } catch (err) {
    console.error(`\n❌ Failed to parse JSON key file at ${keyPath}:`, err.message);
    process.exit(1);
  }

  if (serviceAccount.project_id && serviceAccount.project_id !== EXPECTED_PROJECT_ID) {
    console.warn(
      `\n⚠️ WARNING: Key is for project "${serviceAccount.project_id}", expected "${EXPECTED_PROJECT_ID}".`
    );
  }

  // Initialize Firebase Admin
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id || EXPECTED_PROJECT_ID,
  });

  const auth = admin.auth();
  const db = admin.firestore();

  // 2. Lookup target user in Firebase Authentication
  console.log(`\n🔍 Looking up user in Firebase Auth: ${targetEmail}...`);
  let userRecord;
  try {
    userRecord = await auth.getUserByEmail(targetEmail);
    console.log(`✅ Found user in Firebase Auth:`);
    console.log(`   UID          : ${userRecord.uid}`);
    console.log(`   Email        : ${userRecord.email}`);
    console.log(`   Display Name : ${userRecord.displayName || '(none)'}`);
    console.log(`   Created At   : ${userRecord.metadata.creationTime}`);
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      console.error(`\n❌ User "${targetEmail}" does not exist in Firebase Authentication!`);
      console.error('\n👉 Steps to create the user account:');
      console.error('1. Open Firebase Console: https://console.firebase.google.com/');
      console.error(`2. Select project: "${EXPECTED_PROJECT_ID}"`);
      console.error('3. In the left menu, go to "Build" -> "Authentication" -> "Users" tab.');
      console.error('4. Click "Add user".');
      console.error(`5. Enter Email: ${targetEmail}`);
      console.error('6. Enter a strong password and click "Add user".');
      console.error('7. Re-run this script: npm run bootstrap\n');
      process.exit(1);
    } else {
      console.error('\n❌ Firebase Auth lookup error:', err.message);
      process.exit(1);
    }
  }

  // 3. Check and write document to Firestore /admins/{uid}
  console.log(`\n💾 Provisioning Firestore /admins/${userRecord.uid}...`);
  const adminDocRef = db.collection('admins').doc(userRecord.uid);
  const existingSnap = await adminDocRef.get();

  const nowIso = new Date().toISOString();
  let createdAt = nowIso;

  if (existingSnap.exists) {
    const existingData = existingSnap.data() || {};
    createdAt = existingData.createdAt || nowIso;
    console.log(`ℹ️ Existing admin record found. Updating to ensure super_admin and active status...`);
  } else {
    console.log(`ℹ️ Creating fresh super_admin record in /admins/${userRecord.uid}...`);
  }

  const adminPayload = {
    uid: userRecord.uid,
    email: userRecord.email,
    displayName: userRecord.displayName || userRecord.email.split('@')[0] || 'Super Admin',
    role: 'super_admin',
    active: true,
    createdAt: createdAt,
    updatedAt: nowIso,
  };

  await adminDocRef.set(adminPayload, { merge: true });

  // 4. Set Custom Claims in Firebase Auth
  try {
    await auth.setCustomUserClaims(userRecord.uid, {
      admin: true,
      super_admin: true,
      role: 'super_admin',
    });
    console.log(`✅ Set custom user claims on Firebase Auth record.`);
  } catch (claimErr) {
    console.warn(`⚠️ Note: Could not set custom claims (non-critical):`, claimErr.message);
  }

  // 5. Verify readback
  const verifySnap = await adminDocRef.get();
  if (!verifySnap.exists || verifySnap.data()?.active !== true || verifySnap.data()?.role !== 'super_admin') {
    console.error('\n❌ Verification failed: Firestore document does not reflect super_admin role.');
    process.exit(1);
  }

  console.log('\n============================================================');
  console.log('🎉 SUCCESS: Super Admin Provisioned Successfully!');
  console.log('============================================================');
  console.log(`Email       : ${verifySnap.data().email}`);
  console.log(`UID         : ${verifySnap.id}`);
  console.log(`Role        : ${verifySnap.data().role}`);
  console.log(`Active      : ${verifySnap.data().active}`);
  console.log(`Firestore   : /admins/${verifySnap.id}`);
  console.log('------------------------------------------------------------');
  console.log('You can now log in at:');
  console.log('👉 https://notifyjobsapp.pages.dev');
  console.log('============================================================\n');

  process.exit(0);
}

main().catch((e) => {
  console.error('\n❌ Unexpected error during bootstrap:', e);
  process.exit(1);
});
