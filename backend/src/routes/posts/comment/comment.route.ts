import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import {
    createPostComment,
    deletePostComment,
    getPostComments,
    updatePostComment,
} from "./comment.controller.js";

const router = express.Router();


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
 *   patch:
 *     summary: Chinh sua comment cua post
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
 *     responses:
 *       200:
 *         description: Chinh sua comment thanh cong
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
router.patch("/:postId/comments/:commentId", protectedRoute, updatePostComment);
router.delete("/:postId/comments/:commentId", protectedRoute, deletePostComment);

export default router;
