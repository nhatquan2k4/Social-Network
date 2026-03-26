import express from 'express';
import multer from 'multer';
import { protectedRoute } from '../middlewares/authMiddleware';
import { checkFriendship, checkGroupMembership } from '../middlewares/friendMiddleware';
import {
    sendDirectTextMessage,
    sendDirectMediaMessage,
    sendGroupTextMessage,
    sendGroupMediaMessage,
    sendDirectMessage,
    sendGroupMessage
} from '../controller/messageController';


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
 * /api/messages/direct/text:
 *   post:
 *     summary: Gui tin nhan chu truc tiep cho ban be
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
 *               - recipientId
 *               - conversationId
 *               - content
 *             properties:
 *               recipientId:
 *                 type: string
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *     responses:
 *       201:
 *         description: Gui tin nhan thanh cong
 */
router.post("/direct/text", protectedRoute, checkFriendship, sendDirectTextMessage);

/**
 * @swagger
 * /api/messages/direct/media:
 *   post:
 *     summary: Gui anh truc tiep cho ban be
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - recipientId
 *               - conversationId
 *               - files
 *             properties:
 *               recipientId:
 *                 type: string
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Gui anh thanh cong
 */
router.post("/direct/media", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), checkFriendship, sendDirectMediaMessage);

/**
 * @swagger
 * /api/messages/group/text:
 *   post:
 *     summary: Gui tin nhan chu trong nhom
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
 *               - content
 *             properties:
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *     responses:
 *       201:
 *         description: Gui tin nhan thanh cong
 */
router.post("/group/text", protectedRoute, checkGroupMembership, sendGroupTextMessage);

/**
 * @swagger
 * /api/messages/group/media:
 *   post:
 *     summary: Gui anh trong nhom
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - conversationId
 *               - files
 *             properties:
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *     responses:
 *       201:
 *         description: Gui anh thanh cong
 */
router.post("/group/media", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), checkGroupMembership, sendGroupMediaMessage);

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
 *             $ref: '#/components/schemas/DirectMessageRequest'
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - recipientId
 *               - conversationId
 *             properties:
 *               recipientId:
 *                 type: string
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
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
router.post("/direct", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), checkFriendship, sendDirectMessage);

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
 *             $ref: '#/components/schemas/GroupMessageRequest'
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - conversationId
 *             properties:
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
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
router.post("/group", protectedRoute, upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")), checkGroupMembership, sendGroupMessage);

export default router;