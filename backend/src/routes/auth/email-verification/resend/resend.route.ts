import express from 'express';
import { resendEmailVerification } from './resend.controller.js';

const router = express.Router();
/**
 * @swagger
 * /api/auth/email-verification/resend:
 *   post:
 *     summary: Gui lai email xac thuc
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
 *     responses:
 *       200:
 *         description: Da xu ly gui lai email xac thuc
 *       429:
 *         description: Gui lai qua nhanh
 */
router.post('/email-verification/resend', resendEmailVerification);

export default router;
