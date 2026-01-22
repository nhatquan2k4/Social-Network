import express from 'express';
import {createConversation, getConversations, getMessages} from '../controller/conversationController';
import {protectedRoute} from '../middlewares/authMiddleware';
import {
  checkFriendship,
  checkConversationMembership,
} from "../middlewares/friendMiddleware";

const router = express.Router();

/**
 * @swagger
 * /api/conversations:
 *   post:
 *     summary: Tạo cuộc trò chuyện mới (đơn hoặc nhóm)
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *               - participantIds
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [direct, group]
 *                 description: Loại cuộc trò chuyện
 *                 example: direct
 *               participantIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Danh sách ID người tham gia
 *                 example: ["507f1f77bcf86cd799439011", "507f1f77bcf86cd799439012"]
 *               groupName:
 *                 type: string
 *                 description: Tên nhóm (bắt buộc nếu type là group)
 *                 example: Nhóm học tập
 *     responses:
 *       201:
 *         description: Tạo cuộc trò chuyện thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Tạo cuộc trò chuyện thành công
 *                 conversation:
 *                   $ref: '#/components/schemas/Conversation'
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
router.post("/", protectedRoute, checkFriendship, createConversation);

/**
 * @swagger
 * /api/conversations:
 *   get:
 *     summary: Lấy danh sách cuộc trò chuyện của người dùng
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: recipientId
 *         schema:
 *           type: string
 *         description: ID của người nhận để lọc conversation cụ thể (tùy chọn)
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Danh sách cuộc trò chuyện
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 conversations:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Conversation'
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
router.get("/", protectedRoute, getConversations);

/**
 * @swagger
 * /api/conversations/{conversationId}/messages:
 *   get:
 *     summary: Lấy tin nhắn của một cuộc trò chuyện
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của cuộc trò chuyện
 *         example: 507f1f77bcf86cd799439011
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 50
 *         description: Số lượng tin nhắn tối đa trả về
 *       - in: query
 *         name: before
 *         schema:
 *           type: string
 *           format: date-time
 *         description: Lấy tin nhắn trước thời điểm này (để phân trang)
 *     responses:
 *       200:
 *         description: Danh sách tin nhắn
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 messages:
 *                   type: array
 *                   items:
 *                     allOf:
 *                       - $ref: '#/components/schemas/Message'
 *                       - type: object
 *                         properties:
 *                           senderId:
 *                             $ref: '#/components/schemas/User'
 *       401:
 *         description: Chưa xác thực
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       403:
 *         description: Không có quyền truy cập cuộc trò chuyện này
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy cuộc trò chuyện
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
router.get(
  "/:conversationId/messages",
  protectedRoute,
  checkConversationMembership,
  getMessages,
);

export default router;