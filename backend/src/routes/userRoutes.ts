import express from 'express';
import multer from 'multer';
import { authMe, updateMyAvatar } from '../controller/userController';
import { protectedRoute } from '../middlewares/authMiddleware';

const router = express.Router();
const upload = multer({
	storage: multer.memoryStorage(),
	limits: {
		fileSize: Number(process.env.MEDIA_MAX_FILE_SIZE || "5242880"),
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
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Lỗi server
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/me', protectedRoute, authMe);

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
router.patch('/me/avatar', protectedRoute, upload.array('avatar', 1), updateMyAvatar);

export default router;