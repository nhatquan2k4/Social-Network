import express from 'express';
import { verifyEmail } from './verify.controller';

const router = express.Router();

/**
 * @swagger
 * /api/auth/email-verification/verify:
 *   post:
 *     summary: Xac thuc email bang token
 *     tags: [Authentication]
 *     security: []
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
 *                 description: Verification token gui qua email
 *     responses:
 *       200:
 *         description: Xac thuc email thanh cong
 *       400:
 *         description: Token khong hop le hoac het han
 */
router.post('/email-verification/verify', verifyEmail);

export default router;
