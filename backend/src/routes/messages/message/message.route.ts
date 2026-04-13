import express from "express";
import multer from "multer";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware";
import {
    checkFriendship,
    checkGroupMembership,
} from "../../../shared/middlewares/friend.middleware";
import {
    sendDirectMediaMessage,
    sendDirectMessage,
    sendDirectTextMessage,
    sendGroupMediaMessage,
    sendGroupMessage,
    sendGroupTextMessage,
} from "./message.controller";

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
 *     summary: Gui tin nhan text truc tiep
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
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post("/direct/text", protectedRoute, checkFriendship, sendDirectTextMessage);

/**
 * @swagger
 * /api/messages/direct/media:
 *   post:
 *     summary: Gui media truc tiep
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
 *         description: Gui media thanh cong
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post(
    "/direct/media",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    checkFriendship,
    sendDirectMediaMessage,
);

/**
 * @swagger
 * /api/messages/group/text:
 *   post:
 *     summary: Gui tin nhan text trong nhom
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
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post("/group/text", protectedRoute, checkGroupMembership, sendGroupTextMessage);

/**
 * @swagger
 * /api/messages/group/media:
 *   post:
 *     summary: Gui media trong nhom
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
 *         description: Gui media thanh cong
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post(
    "/group/media",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    checkGroupMembership,
    sendGroupMediaMessage,
);

/**
 * @swagger
 * /api/messages/direct:
 *   post:
 *     summary: Gui tin nhan direct (text hoac media)
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
 *             properties:
 *               recipientId:
 *                 type: string
 *               conversationId:
 *                 type: string
 *               content:
 *                 type: string
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
 *         description: Gui tin nhan thanh cong
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post(
    "/direct",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    checkFriendship,
    sendDirectMessage,
);

/**
 * @swagger
 * /api/messages/group:
 *   post:
 *     summary: Gui tin nhan nhom (text hoac media)
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
 *               content:
 *                 type: string
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
 *         description: Gui tin nhan thanh cong
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen
 *       500:
 *         description: Loi he thong
 */
router.post(
    "/group",
    protectedRoute,
    upload.array("files", Number(process.env.MEDIA_MAX_FILES || "10")),
    checkGroupMembership,
    sendGroupMessage,
);

export default router;
