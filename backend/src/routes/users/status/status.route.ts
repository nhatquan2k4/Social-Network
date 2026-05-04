import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { getOnlineStatuses } from "./status.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/users/status:
 *   post:
 *     summary: Query online status cho 1 hoac nhieu user
 *     description: |
 *       Tra ve trang thai online/offline va lastSeenAt cho danh sach userIds.
 *       Su dung cho ca single user lan batch query.
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userIds
 *             properties:
 *               userIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 minItems: 1
 *                 maxItems: 100
 *                 description: Danh sach userId can kiem tra (toi da 100)
 *                 example: ["665a1b2c3d4e5f6a7b8c9d0e", "665a1b2c3d4e5f6a7b8c9d0f"]
 *     responses:
 *       200:
 *         description: Danh sach trang thai online
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       userId:
 *                         type: string
 *                       isOnline:
 *                         type: boolean
 *                       lastSeenAt:
 *                         type: string
 *                         format: date-time
 *                         nullable: true
 *                         description: Null neu user dang online
 *       400:
 *         description: userIds khong hop le
 *       401:
 *         description: Chua xac thuc
 */
router.post("/status", protectedRoute, getOnlineStatuses);

export default router;
