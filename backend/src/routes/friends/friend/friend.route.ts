import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware";
import { getAllFriend } from "./friend.controller";

const router = express.Router();
/**
 * @swagger
 * /api/friends:
 *   get:
 *     summary: Lấy danh sách bạn bè
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách bạn bè
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 friends:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                         description: ID của mối quan hệ bạn bè
 *                       userId:
 *                         $ref: '#/components/schemas/User'
 *                       friendId:
 *                         $ref: '#/components/schemas/User'
 *                       createdAt:
 *                         type: string
 *                         format: date-time
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
router.get("/", protectedRoute, getAllFriend);

export default router;
