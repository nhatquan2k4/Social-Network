import express from 'express';
import { protectedRoute } from '../middlewares/authMiddleware';
import {
  getMyNotifications,
  markAllNotificationsAsRead,
  markNotificationAsRead,
} from '../controller/notificationController';

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

export default router;
