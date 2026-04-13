import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware";
import {
    addOrUpdateMessageReaction,
    removeMessageReaction,
} from "./reaction.controller";

const router = express.Router();

/**
 * @swagger
 * /api/messages/{messageId}/reaction:
 *   put:
 *     summary: Them hoac cap nhat reaction cho tin nhan
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
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
router.put(
    "/:messageId/reaction",
    protectedRoute,
    addOrUpdateMessageReaction,
);

/**
 * @swagger
 * /api/messages/{messageId}/reaction:
 *   delete:
 *     summary: Go reaction cua toi khoi tin nhan
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: messageId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Da go reaction
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
router.delete(
    "/:messageId/reaction",
    protectedRoute,
    removeMessageReaction,
);

export default router;
