import { initializeApp, cert } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { createRequire } from 'module';

// Tạo hàm require để nạp file JSON
const require = createRequire(import.meta.url);
const serviceAccount = require('./firebase-service-account.json');

// Khởi tạo Firebase bằng cú pháp Modular mới
initializeApp({
  credential: cert(serviceAccount),
});

// Xuất đối tượng messaging để sử dụng
export const fcm = getMessaging();