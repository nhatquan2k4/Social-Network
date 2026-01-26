import express from 'express';
import { protectedRoute } from '../../middlewares/authMiddleware';
import {
    sharePost,
    getShareById,
    updateShare,
    deleteShare,
    getSharesByPost,
    getSharesByUser,
    checkUserShared
} from '../../controller/Post/shareController';

const router = express.Router();

/**
 * @swagger
 * /api/shares:
 *   post:
 *     summary: Share một bài viết
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - originalPostId
 *             properties:
 *               originalPostId:
 *                 type: string
 *                 description: ID của bài viết gốc
 *                 example: 507f1f77bcf86cd799439011
 *               caption:
 *                 type: string
 *                 description: Lời bình khi share
 *                 maxLength: 500
 *                 example: Bài viết rất hay, chia sẻ cho mọi người cùng xem!
 *     responses:
 *       201:
 *         description: Share bài viết thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Share bai viet thanh cong
 *                 share:
 *                   $ref: '#/components/schemas/Share'
 *                 sharePost:
 *                   $ref: '#/components/schemas/Post'
 *       400:
 *         description: Dữ liệu không hợp lệ hoặc đã share rồi
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
 *         description: Không tìm thấy bài viết
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
router.post("/", protectedRoute, sharePost);

/**
 * @swagger
 * /api/shares/{shareId}:
 *   get:
 *     summary: Lấy thông tin chi tiết một share
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shareId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của share
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Lấy thông tin thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 share:
 *                   $ref: '#/components/schemas/Share'
 *       401:
 *         description: Chưa xác thực
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy share
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
router.get("/:shareId", protectedRoute, getShareById);

/**
 * @swagger
 * /api/shares/{shareId}:
 *   put:
 *     summary: Cập nhật caption của share
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shareId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của share
 *         example: 507f1f77bcf86cd799439011
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - caption
 *             properties:
 *               caption:
 *                 type: string
 *                 description: Lời bình mới
 *                 maxLength: 500
 *                 example: Nội dung đã được chỉnh sửa
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Cap nhat share thanh cong
 *                 share:
 *                   $ref: '#/components/schemas/Share'
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
 *         description: Không có quyền chỉnh sửa
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy share
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
router.put("/:shareId", protectedRoute, updateShare);

/**
 * @swagger
 * /api/shares/{shareId}:
 *   delete:
 *     summary: Xóa share (bỏ share)
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shareId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của share
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Xóa share thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Xoa share thanh cong
 *       401:
 *         description: Chưa xác thực
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       403:
 *         description: Không có quyền xóa
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Không tìm thấy share
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
router.delete("/:shareId", protectedRoute, deleteShare);

/**
 * @swagger
 * /api/shares/post/{postId}:
 *   get:
 *     summary: Lấy danh sách shares của một bài viết
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết gốc
 *         example: 507f1f77bcf86cd799439011
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Số lượng shares tối đa
 *       - in: query
 *         name: skip
 *         schema:
 *           type: integer
 *           default: 0
 *         description: Số lượng shares bỏ qua
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 shares:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Share'
 *                 totalCount:
 *                   type: integer
 *                   description: Tổng số shares
 *                 pagination:
 *                   type: object
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
router.get("/post/:postId", protectedRoute, getSharesByPost);

/**
 * @swagger
 * /api/shares/user/{userId}:
 *   get:
 *     summary: Lấy danh sách shares của một người dùng
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của người dùng
 *         example: 507f1f77bcf86cd799439011
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Số lượng shares tối đa
 *       - in: query
 *         name: skip
 *         schema:
 *           type: integer
 *           default: 0
 *         description: Số lượng shares bỏ qua
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 shares:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Share'
 *                 totalCount:
 *                   type: integer
 *                   description: Tổng số shares
 *                 pagination:
 *                   type: object
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
router.get("/user/:userId", protectedRoute, getSharesByUser);

/**
 * @swagger
 * /api/shares/check/{postId}:
 *   get:
 *     summary: Kiểm tra user hiện tại đã share post chưa
 *     tags: [Shares]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của bài viết
 *         example: 507f1f77bcf86cd799439011
 *     responses:
 *       200:
 *         description: Kiểm tra thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 hasShared:
 *                   type: boolean
 *                   description: User đã share hay chưa
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
router.get("/check/:postId", protectedRoute, checkUserShared);

export default router;
