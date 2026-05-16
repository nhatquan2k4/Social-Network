import * as admin from 'firebase-admin';
import * as path from 'path';

// Đường dẫn tới file JSON cấu hình của bạn
const serviceAccount = require(path.resolve(__dirname, './firebase-service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Xuất đối tượng messaging để sử dụng ở các nơi khác trong dự án
export const fcm = admin.messaging();