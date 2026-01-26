import express from 'express';
import { protectedRoute } from '../../middlewares/authMiddleware';
import {
    reactToPost,
    unreactPost,
    getReactionsByPost,
    getReactionByUserAndPost
} from '../../controller/Post/reactionController';

const router = express.Router();

/**
 * @swagger
 * /api/reactions/{postId}:
 *   post:
 *     summary: React vào bài viết
 *     tags: [Reactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết
 *         example: 507f1f77bcf86cd799439011
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reactionType
 *             properties:
 *               reactionType:
 *                 type: string
 *                 enum: [like, love, haha, wow, sad, angry]
 *                 description: Loại reaction
 *                 example: like
 *     responses:
 *       200:
 *         description: React thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Da react thanh cong
 *                 action:
 *                   type: string
 *                   enum: [reacted, unreacted, changed]
 *                   description: Hành động đã thực hiện
 *                 reactionType:
 *                   type: string
 *                   description: Loại reaction
 *       400:
 *         description: Dữ liệu không hợp lệ
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Chưa xác thực
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy bài viết
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
router.post("/:postId", protectedRoute, reactToPost);

/**
 * @swagger
 * /api/reactions/{postId}:
 *   delete:
 *     summary: Bỏ react bài viết
 *     tags: [Reactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Bỏ react thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Da bo reaction
 *       400:
 *         description: Chưa react bài viết này
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Chưa xác thực
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
router.delete("/:postId", protectedRoute, unreactPost);

/**
 * @swagger
 * /api/reactions/{postId}/list:
 *   get:
 *     summary: Lấy danh sách reactions của bài viết
 *     tags: [Reactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết
 *         example: 507f1f77bcf86cd799439011
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 50
 *         description: Số lượng reactions tối đa
 *       - in: query
 *         name: skip
 *         schema:
 *           type: integer
 *           default: 0
 *         description: Số lượng reactions bỏ qua
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 reactions:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Reaction'
 *                 totalCount:
 *                   type: integer
 *                   description: Tổng số reactions
 *                 countByType:
 *                   type: object
 *                   description: Số lượng reactions theo từng loại
 *                   example: { "like": 10, "love": 5, "haha": 2 }
 *       401:
 *         description: Chưa xác thực
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
router.get("/:postId/list", protectedRoute, getReactionsByPost);

/**
 * @swagger
 * /api/reactions/{postId}/user:
 *   get:
 *     summary: Kiểm tra reaction của user hiện tại cho bài viết
 *     tags: [Reactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Lấy thông tin thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 hasReacted:
 *                   type: boolean
 *                   description: User đã react hay chưa
 *                 reaction:
 *                   $ref: '#/components/schemas/Reaction'
 *       401:
 *         description: Chưa xác thực
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
router.get("/:postId/user", protectedRoute, getReactionByUserAndPost);

export default router;
