import * as admin from 'firebase-admin';
import { createRequire } from 'module';

// Tạo hàm require tương thích với môi trường ES Module
const require = createRequire(import.meta.url);

// Nạp file json chứa khóa bí mật
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const fcm = admin.messaging();