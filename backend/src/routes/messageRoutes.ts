import express from 'express';
import { protectedRoute } from '../middlewares/authMiddleware';
import { checkFriendship, checkGroupMembership } from '../middlewares/friendMiddleware';
import {
    sendDirectMessage,
    sendGroupMessage
} from '../controller/messageController';


const router = express.Router();

/**
 * @swagger
 * /api/messages/direct:
 *   post:
 *     summary: Gửi tin nhắn trực tiếp cho bạn bè
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - receiverId
 *             properties:
 *               receiverId:
 *                 type: string
 *                 description: ID người nhận (phải là bạn bè)
 *                 example: 507f1f77bcf86cd799439011
 *               content:
 *                 type: string
 *                 description: Nội dung tin nhắn
 *                 example: Xin chào, bạn khỏe không?
 *               imgUrl:
 *                 type: string
 *                 description: URL hình ảnh (tùy chọn)
 *                 example: https://example.com/image.jpg
 *     responses:
 *       201:
 *         description: Gửi tin nhắn thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Gửi tin nhắn thành công
 *                 data:
 *                   $ref: '#/components/schemas/Message'
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
 *       403:
 *         description: Không có quyền (không phải bạn bè)
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
router.post("/direct", protectedRoute, checkFriendship, sendDirectMessage);

/**
 * @swagger
 * /api/messages/group:
 *   post:
 *     summary: Gửi tin nhắn trong nhóm
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - conversationId
 *             properties:
 *               conversationId:
 *                 type: string
 *                 description: ID cuộc trò chuyện nhóm
 *                 example: 507f1f77bcf86cd799439011
 *               content:
 *                 type: string
 *                 description: Nội dung tin nhắn
 *                 example: Xin chào mọi người!
 *               imgUrl:
 *                 type: string
 *                 description: URL hình ảnh (tùy chọn)
 *                 example: https://example.com/image.jpg
 *     responses:
 *       201:
 *         description: Gửi tin nhắn thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Gửi tin nhắn nhóm thành công
 *                 data:
 *                   $ref: '#/components/schemas/Message'
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
 *       403:
 *         description: Không có quyền (không phải thành viên nhóm)
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
router.post("/group", protectedRoute, checkGroupMembership, sendGroupMessage);

export default router;