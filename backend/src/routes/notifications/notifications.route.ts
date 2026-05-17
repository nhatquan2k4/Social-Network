import express from 'express';
import { protectedRoute } from '../../shared/middlewares/auth.middleware.js';
import {
  getMyNotifications,
  markAllNotificationsAsRead,
  markNotificationAsRead,
  saveFcmToken,
  removeFcmToken,
  testSendNotification,
} from './notifications.controller.js';

const router = express.Router();

/**
 * @swagger
 * /api/notifications:
 *   get:
 *     summary: Lay danh sach thong bao cua toi
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *       - in: query
 *         name: unreadOnly
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: Danh sach thong bao
 */
router.get('/', protectedRoute, getMyNotifications);

/**
 * @swagger
 * /api/notifications/fcm-token:
 *   post:
 *     summary: Luu FCM token cua thiet bi
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *               platform:
 *                 type: string
 *                 enum: [android, ios, web]
 *     responses:
 *       200:
 *         description: Luu FCM token thanh cong
 */
router.post('/fcm-token', protectedRoute, saveFcmToken);

/**
 * @swagger
 * /api/notifications/{notificationId}/read:
 *   patch:
 *     summary: Danh dau mot thong bao da doc
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: notificationId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Da danh dau da doc
 */
router.patch('/:notificationId/read', protectedRoute, markNotificationAsRead);

/**
 * @swagger
 * /api/notifications/read-all:
 *   patch:
 *     summary: Danh dau tat ca thong bao da doc
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Da danh dau tat ca notification da doc
 */
router.patch('/read-all', protectedRoute, markAllNotificationsAsRead);

/**
 * @swagger
 * /api/notifications/test-send:
 *   post:
 *     summary: Gui thong bao test den mot thiet bi (Chi dung de dev)
 *     tags: [Notifications]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *     responses:
 *       200:
 *         description: Đã gửi thành công
 */
router.post('/test-send', testSendNotification);

// Trong file notifications.route.ts
router.delete('/fcm-token', protectedRoute, removeFcmToken);
// Thêm route này vào file định tuyến của bạn
router.post('/remove-fcm-token', protectedRoute, removeFcmToken);

export default router;