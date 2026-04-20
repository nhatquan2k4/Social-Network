import express from "express";
import multer from "multer";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { createPost, deletePost, getPostById, updatePost } from "./post.controller.js";

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
 * /api/posts:
 *   post:
 *     summary: Tao bai viet moi
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Tao post thanh cong
 */
router.post(
    "/",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    createPost,
);

/**
 * @swagger
 * /api/posts/{postId}:
 *   get:
 *     summary: Lay chi tiet post
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Chi tiet post
 */
router.get("/:postId", protectedRoute, getPostById);

/**
 * @swagger
 * /api/posts/{postId}:
 *   patch:
 *     summary: Chinh sua post
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       200:
 *         description: Chinh sua post thanh cong
 */
router.patch(
    "/:postId",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    updatePost,
);

/**
 * @swagger
 * /api/posts/{postId}:
 *   delete:
 *     summary: Xoa post
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Xoa post thanh cong
 */
router.delete("/:postId", protectedRoute, deletePost);

export default router;
