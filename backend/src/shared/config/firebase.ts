import {
  cert,
  getApp,
  getApps,
  initializeApp,
  type ServiceAccount,
} from 'firebase-admin/app';
import { getMessaging, type Messaging } from 'firebase-admin/messaging';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);

const shouldUseMockFirebase = () =>
  process.env.E2E_EXTERNAL_SERVICES === 'mock' ||
  process.env.NODE_ENV === 'test' ||
  process.env.IS_E2E === 'true';

const createMockMessaging = (): Pick<Messaging, 'send'> => ({
  async send() {
    return 'mock-fcm-message-id';
  },
});

const parseServiceAccountJson = (
  rawValue: string,
  sourceName: string,
): ServiceAccount => {
  try {
    return JSON.parse(rawValue) as ServiceAccount;
  } catch (error) {
    throw new Error(
      `Invalid Firebase service account JSON from ${sourceName}: ${(error as Error).message}`,
    );
  }
};

const loadServiceAccount = (): ServiceAccount => {
  const serviceAccountBase64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64?.trim();
  if (serviceAccountBase64) {
    const decodedValue = Buffer.from(serviceAccountBase64, 'base64').toString('utf8');
    return parseServiceAccountJson(decodedValue, 'FIREBASE_SERVICE_ACCOUNT_BASE64');
  }

  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (serviceAccountJson) {
    return parseServiceAccountJson(serviceAccountJson, 'FIREBASE_SERVICE_ACCOUNT_JSON');
  }

  const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH?.trim() || './firebase-service-account.json';

  try {
    return require(serviceAccountPath) as ServiceAccount;
  } catch (error) {
    throw new Error(
      `Firebase service account could not be loaded from ${serviceAccountPath}. ` +
        `Set FIREBASE_SERVICE_ACCOUNT_BASE64 in the production env file. ` +
        `Original error: ${(error as Error).message}`,
    );
  }
};

const createMessaging = (): Pick<Messaging, 'send'> => {
  if (shouldUseMockFirebase()) {
    return createMockMessaging();
  }

  try {
    const firebaseApp =
      getApps().length > 0
        ? getApp()
        : initializeApp({
            credential: cert(loadServiceAccount()),
          });

    return getMessaging(firebaseApp);
  } catch (error) {
    if (process.env.NODE_ENV === 'production') {
      throw error;
    }

    console.warn(`Firebase is unavailable. Using mock FCM sender. ${(error as Error).message}`);
    return createMockMessaging();
  }
};

export const fcm = createMessaging();
