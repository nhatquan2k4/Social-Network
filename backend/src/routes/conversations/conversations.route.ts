import express from 'express';
import { createConversation, getConversations, getMessages, markAsSeen } from './conversations.controller';
import {protectedRoute} from '../../shared/middlewares/auth.middleware';
import {
  checkFriendship,
  checkConversationMembership,
} from "../../shared/middlewares/friend.middleware";
import {
  addOrUpdateMessageReaction,
  markMessagesAsReadBulk,
  markMessageAsRead,
  removeMessageReaction,
} from "../messages/messages.controller";

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
 *             oneOf:
 *               - $ref: '#/components/schemas/ConversationDirectCreateRequest'
 *               - $ref: '#/components/schemas/ConversationGroupCreateRequest'
 *           examples:
 *             direct:
 *               summary: Tao direct conversation
 *               value:
 *                 type: direct
 *                 recipientId: 507f1f77bcf86cd799439011
 *             group:
 *               summary: Tao group conversation
 *               value:
 *                 type: group
 *                 name: Nhom hoc tap
 *                 memberIds:
 *                   - 507f1f77bcf86cd799439011
 *                   - 507f1f77bcf86cd799439012
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
 * /api/conversations/{conversationId}/seen:
 *   patch:
 *     summary: Danh dau da xem cuoc tro chuyen
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Da cap nhat trang thai seen
 */
router.patch(
  "/:conversationId/seen",
  protectedRoute,
  checkConversationMembership,
  markAsSeen,
);

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

/**
 * @swagger
 * /api/conversations/{conversationId}/messages/{messageId}/reaction:
 *   put:
 *     summary: Them hoac cap nhat reaction cho tin nhan
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: messageId
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
 *               - emoji
 *             properties:
 *               emoji:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cap nhat reaction thanh cong
 *   delete:
 *     summary: Go reaction cua toi khoi tin nhan
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: messageId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Da go reaction
 */
router.put(
  "/:conversationId/messages/:messageId/reaction",
  protectedRoute,
  checkConversationMembership,
  addOrUpdateMessageReaction,
);
router.delete(
  "/:conversationId/messages/:messageId/reaction",
  protectedRoute,
  checkConversationMembership,
  removeMessageReaction,
);

/**
 * @swagger
 * /api/conversations/{conversationId}/messages/{messageId}/read:
 *   patch:
 *     summary: Danh dau tin nhan da doc
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: messageId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Da danh dau da doc
 */
router.patch(
  "/:conversationId/messages/:messageId/read",
  protectedRoute,
  checkConversationMembership,
  markMessageAsRead,
);

/**
 * @swagger
 * /api/conversations/{conversationId}/messages/read-all:
 *   patch:
 *     summary: Danh dau da doc hang loat den lastMessageId
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               lastMessageId:
 *                 type: string
 *                 description: Neu co, danh dau da doc toi tin nhan nay. Neu khong co, danh dau tat ca.
 *     responses:
 *       200:
 *         description: Da danh dau da doc hang loat
 */
router.patch(
  "/:conversationId/messages/read-all",
  protectedRoute,
  checkConversationMembership,
  markMessagesAsReadBulk,
);

export default router;