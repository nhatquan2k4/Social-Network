import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { toggleLikePost } from "./like.controller.js";

const router = express.Router();


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

export default router;
