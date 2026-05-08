import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import {
    blockUser,
    getBlockedUsers,
    unblockUser,
} from "./block.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/friends/blocks:
 *   post:
 *     summary: Block mot nguoi dung
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Block thanh cong
 *   get:
 *     summary: Lay danh sach nguoi dung da bi block boi toi
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sach block
 */
router.post("/blocks", protectedRoute, blockUser);
router.get("/blocks", protectedRoute, getBlockedUsers);

/**
 * @swagger
 * /api/friends/blocks/{userId}:
 *   delete:
 *     summary: Bo block mot nguoi dung
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Bo block thanh cong
 */
router.delete("/blocks/:userId", protectedRoute, unblockUser);

export default router;

