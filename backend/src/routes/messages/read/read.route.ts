import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware";
import { checkConversationMembership } from "../../../shared/middlewares/friend.middleware";
import {
    getConversationMessages,
    markMessageAsRead,
    markMessagesAsReadBulk,
} from "./read.controller";

const router = express.Router();

/**
 * @swagger
 * /api/messages/{conversationId}/messages:
 *   get:
 *     summary: Lay lich su tin nhan theo conversation voi cursor pagination
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: conversationId
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: limit
 *         required: false
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 30
 *         description: So tin nhan moi trang
 *       - in: query
 *         name: cursor
 *         required: false
 *         schema:
 *           type: string
 *         description: Cursor base64url gom createdAt va _id cua tin nhan bien
 *     responses:
 *       200:
 *         description: Lay lich su tin nhan thanh cong
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Message'
 *                 pageInfo:
 *                   type: object
 *                   properties:
 *                     hasMore:
 *                       type: boolean
 *                     limit:
 *                       type: integer
 *                     nextCursor:
 *                       type: string
 *                       nullable: true
 *       400:
 *         description: Query khong hop le (limit/cursor)
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen truy cap conversation
 *       404:
 *         description: Khong tim thay conversation
 *       500:
 *         description: Loi he thong
 */
router.get(
    "/:conversationId/messages",
    protectedRoute,
    checkConversationMembership,
    getConversationMessages,
);

/**
 * @swagger
 * /api/messages/{conversationId}/messages/{messageId}/read:
 *   patch:
 *     summary: Danh dau tin nhan da doc
 *     tags: [Messages]
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
 *         description: Da danh dau tin nhan da doc
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen truy cap conversation
 *       404:
 *         description: Khong tim thay tin nhan
 *       500:
 *         description: Loi he thong
 */
router.patch(
    "/:conversationId/messages/:messageId/read",
    protectedRoute,
    checkConversationMembership,
    markMessageAsRead,
);

/**
 * @swagger
 * /api/messages/{conversationId}/messages/read-all:
 *   patch:
 *     summary: Danh dau da doc nhieu tin nhan trong conversation
 *     tags: [Messages]
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
 *                 description: Neu co, danh dau da doc den message nay
 *     responses:
 *       200:
 *         description: Da danh dau da doc hang loat
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen truy cap conversation
 *       404:
 *         description: Khong tim thay tin nhan
 *       500:
 *         description: Loi he thong
 */
router.patch(
    "/:conversationId/messages/read-all",
    protectedRoute,
    checkConversationMembership,
    markMessagesAsReadBulk,
);

export default router;
