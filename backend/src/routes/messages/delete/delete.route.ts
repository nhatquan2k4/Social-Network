import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { checkConversationMembership } from "../../../shared/middlewares/friend.middleware.js";
import { deleteMessageForEveryone } from "./delete.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/messages/{conversationId}/messages/{messageId}:
 *   delete:
 *     summary: Go tin nhan cho tat ca nguoi trong conversation
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
 *         description: Go tin nhan thanh cong va emit message:deleted
 *       400:
 *         description: Du lieu khong hop le
 *       401:
 *         description: Chua xac thuc
 *       403:
 *         description: Khong co quyen go tin nhan
 *       404:
 *         description: Khong tim thay conversation hoac tin nhan
 */
router.delete(
    "/:conversationId/messages/:messageId",
    protectedRoute,
    checkConversationMembership,
    deleteMessageForEveryone,
);

export default router;

