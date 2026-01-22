import express from 'express';
import { protectedRoute } from '../middlewares/authMiddleware';

import {
    sendFriendRequest,
    acceptFriendRequest,
    rejectFriendRequest,
    getAllFriend,
    getAllFriendRequest
} from '../controller/friendController';

const router = express.Router();

/**
 * @swagger
 * /api/friends/requests:
 *   post:
 *     summary: Gửi lời mời kết bạn
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
 *               - toUserId
 *             properties:
 *               toUserId:
 *                 type: string
 *                 description: ID người dùng nhận lời mời
 *                 example: 507f1f77bcf86cd799439011
 *               message:
 *                 type: string
 *                 description: Lời nhắn kèm theo (tùy chọn, tối đa 300 ký tự)
 *                 maxLength: 300
 *                 example: Xin chào, hãy kết bạn với tôi!
 *     responses:
 *       201:
 *         description: Gửi lời mời thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Gửi lời mời kết bạn thành công
 *                 friendRequest:
 *                   $ref: '#/components/schemas/FriendRequest'
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
 *       409:
 *         description: Lời mời đã tồn tại
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
router.post("/requests", protectedRoute, sendFriendRequest);

/**
 * @swagger
 * /api/friends/requests/{requestId}/accept:
 *   post:
 *     summary: Chấp nhận lời mời kết bạn
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của lời mời kết bạn
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Chấp nhận lời mời thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Chấp nhận lời mời kết bạn thành công
 *       400:
 *         description: Lời mời không hợp lệ
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
 *       404:
 *         description: Không tìm thấy lời mời
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
router.post("/requests/:requestId/accept", protectedRoute, acceptFriendRequest);

/**
 * @swagger
 * /api/friends/requests/{requestId}/reject:
 *   post:
 *     summary: Từ chối lời mời kết bạn
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của lời mời kết bạn
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Từ chối lời mời thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Từ chối lời mời kết bạn thành công
 *       400:
 *         description: Lời mời không hợp lệ
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
 *       404:
 *         description: Không tìm thấy lời mời
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
router.post("/requests/:requestId/reject", protectedRoute, rejectFriendRequest);

/**
 * @swagger
 * /api/friends:
 *   get:
 *     summary: Lấy danh sách bạn bè
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách bạn bè
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 friends:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                         description: ID của mối quan hệ bạn bè
 *                       userId:
 *                         $ref: '#/components/schemas/User'
 *                       friendId:
 *                         $ref: '#/components/schemas/User'
 *                       createdAt:
 *                         type: string
 *                         format: date-time
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
router.get("/", protectedRoute, getAllFriend);

/**
 * @swagger
 * /api/friends/requests:
 *   get:
 *     summary: Lấy danh sách lời mời kết bạn
 *     tags: [Friends]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Danh sách lời mời kết bạn
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 friendRequests:
 *                   type: array
 *                   items:
 *                     allOf:
 *                       - $ref: '#/components/schemas/FriendRequest'
 *                       - type: object
 *                         properties:
 *                           from:
 *                             $ref: '#/components/schemas/User'
 *                           to:
 *                             $ref: '#/components/schemas/User'
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
router.get("/requests", protectedRoute, getAllFriendRequest);

export default router;