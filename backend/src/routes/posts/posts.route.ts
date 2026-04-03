import express from "express";
import multer from "multer";
import { protectedRoute } from "../../shared/middlewares/auth.middleware";
import {
  createPost,
  createPostComment,
  deletePost,
  deletePostComment,
  getFeed,
  getPostComments,
  getPostById,
  reportPost,
  toggleLikePost,
  updatePost,
} from "./posts.controller";

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
router.post("/", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), createPost);

/**
 * @swagger
 * /api/posts/feed:
 *   get:
 *     summary: Lay feed bai viet
 *     tags: [Posts]
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
 *     responses:
 *       200:
 *         description: Feed bai viet
 */
router.get("/feed", protectedRoute, getFeed);

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
router.patch("/:postId", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), updatePost);

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

/**
 * @swagger
 * /api/posts/{postId}/like:
 *   post:
 *     summary: Like hoac unlike post
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
 *         description: Cap nhat like thanh cong
 */
router.post("/:postId/like", protectedRoute, toggleLikePost);

/**
 * @swagger
 * /api/posts/{postId}/report:
 *   post:
 *     summary: Bao cao bai viet
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
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reason
 *             properties:
 *               reason:
 *                 type: string
 *                 enum: [spam, harassment, falseInfo, hateSpeech, violence, other]
 *     responses:
 *       200:
 *         description: Bao cao thanh cong
 */
router.post("/:postId/report", protectedRoute, reportPost);

/**
 * @swagger
 * /api/posts/{postId}/comments:
 *   post:
 *     summary: Tao comment cho post
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
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - content
 *             properties:
 *               content:
 *                 type: string
 *               parentCommentId:
 *                 type: string
 *                 description: ID comment cha (bo trong neu la comment goc)
 *     responses:
 *       201:
 *         description: Tao comment thanh cong
 *   get:
 *     summary: Lay danh sach comment cua post
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
 *         description: Danh sach comment dang cay (nested)
 */
router.post("/:postId/comments", protectedRoute, createPostComment);
router.get("/:postId/comments", protectedRoute, getPostComments);

/**
 * @swagger
 * /api/posts/{postId}/comments/{commentId}:
 *   delete:
 *     summary: Xoa comment cua post
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: commentId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Xoa comment thanh cong
 */
router.delete("/:postId/comments/:commentId", protectedRoute, deletePostComment);

export default router;
