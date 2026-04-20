import express from 'express';
import multer from 'multer';
import { protectedRoute } from '../../../shared/middlewares/auth.middleware.js';
import { uploadMedia } from './upload.controller.js';

const router = express.Router();

const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: Number(process.env.MEDIA_MAX_FILE_SIZE || '5242880'),
        files: Number(process.env.MEDIA_MAX_FILES || '10'),
    },
});

/**
 * @swagger
 * /api/media/upload:
 *   post:
 *     summary: Upload media len MinIO
 *     tags: [Media]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - files
 *             properties:
 *               purpose:
 *                 type: string
 *                 enum: [post, message, avatar]
 *               conversationId:
 *                 type: string
 *                 description: Bat buoc khi purpose=message de phan loai media theo doan chat
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Upload media thanh cong
 */
router.post(
    '/upload',
    protectedRoute,
    upload.array('files', Number(process.env.MEDIA_MAX_FILES || '10')),
    uploadMedia,
);

export default router;
