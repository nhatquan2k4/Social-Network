import express from 'express';
import multer from 'multer';
import { protectedRoute } from '../../../shared/middlewares/auth.middleware';
import { getMe, getUserProfile, updateAvatar, updateMe } from './profile.controller';

const router = express.Router();

const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: Number(process.env.MEDIA_MAX_FILE_SIZE || '5242880'),
        files: 1,
    },
});

/**
 * @swagger
 * /api/users/me:
 *   get:
 *     summary: Lấy thông tin người dùng hiện tại
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Thông tin người dùng
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       401:
 *         description: Chưa xác thực hoặc token không hợp lệ
 *       500:
 *         description: Lỗi server
 */
router.get('/me', protectedRoute, getMe);

/**
 * @swagger
 * /api/users/me:
 *   patch:
 *     summary: Cap nhat thong tin nguoi dung hien tai
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               displayName:
 *                 type: string
 *               bio:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cap nhat thong tin thanh cong
 */

router.patch('/me', protectedRoute, updateMe);

/**
 * @swagger
 * /api/users/me/avatar:
 *   patch:
 *     summary: Cap nhat avatar nguoi dung hien tai
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - avatar
 *             properties:
 *               avatar:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Cap nhat avatar thanh cong
 *       400:
 *         description: Du lieu upload khong hop le
 *       401:
 *         description: Chua xac thuc
 */
router.patch('/me/avatar', protectedRoute, upload.array('avatar', 1), updateAvatar);

/**
 * @swagger
 * /api/users/{userId}/profile:
 *   get:
 *     summary: Lay thong tin profile va thong ke co ban cua user
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Thong tin profile va stats
 */
router.get('/:userId/profile', protectedRoute, getUserProfile);

export default router;
