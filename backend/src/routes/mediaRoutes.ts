import express from "express";
import multer from "multer";
import { uploadMedia } from "../controller/mediaController";
import { protectedRoute } from "../middlewares/authMiddleware";

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: Number(process.env.MEDIA_MAX_FILE_SIZE || "5242880"),
    files: Number(process.env.MEDIA_MAX_FILES || "10"),
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
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Upload media thanh cong
 */
router.post("/upload", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), uploadMedia);

export default router;
