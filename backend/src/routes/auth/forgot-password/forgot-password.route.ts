import express from 'express';
import { forgotPassword } from './forgot-password.controller.js';

const router = express.Router();

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Quên mật khẩu - gửi mật khẩu mới qua email
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Địa chỉ email đã đăng ký
 *                 example: user@example.com
 *     responses:
 *       200:
 *         description: Mật khẩu mới đã được gửi qua email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Mat khau moi da duoc gui den email cua ban
 *       400:
 *         description: Thiếu email hoặc email không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy tài khoản với email này
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
router.post('/forgot-password', forgotPassword);

export default router;
