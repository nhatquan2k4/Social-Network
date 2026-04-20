import express from 'express';
import { register } from './register.controller.js';

const router = express.Router();

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Đăng ký người dùng mới
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - password
 *               - email
 *               - firstName
 *               - lastName
 *             properties:
 *               username:
 *                 type: string
 *                 description: Tên đăng nhập duy nhất
 *                 example: john_doe
 *               password:
 *                 type: string
 *                 format: password
 *                 description: Mật khẩu
 *                 example: Password123!
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Địa chỉ email
 *                 example: john@example.com
 *               firstName:
 *                 type: string
 *                 description: Tên
 *                 example: John
 *               lastName:
 *                 type: string
 *                 description: Họ
 *                 example: Doe
 *     responses:
 *       201:
 *         description: Đăng ký thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Đăng ký thành công
 *                 user:
 *                   $ref: '#/components/schemas/User'
 *       400:
 *         description: Thiếu thông tin bắt buộc
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       409:
 *         description: Username hoặc email đã tồn tại
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
router.post('/register', register);

export default router;
