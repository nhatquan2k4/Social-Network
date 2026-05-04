import express from "express";
import { protectedRoute } from "../../shared/middlewares/auth.middleware.js";
import { adminRoute } from "../../shared/middlewares/admin.middleware.js";
import {
    getPendingReports,
    getReportsByPost,
    hidePost,
    restorePost,
    deletePost,
    reviewReport,
} from "./admin.controller.js";

const router = express.Router();

// Tất cả admin routes yêu cầu: authenticated + role = "admin"

/**
 * @swagger
 * /api/admin/reports:
 *   get:
 *     summary: Lay danh sach reports dang pending
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Danh sach reports pending
 *       403:
 *         description: Khong co quyen admin
 */
router.get("/reports", protectedRoute, adminRoute, getPendingReports);

/**
 * @swagger
 * /api/admin/reports/post/{postId}:
 *   get:
 *     summary: Lay tat ca reports cua 1 post
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Chi tiet reports cua post
 *       404:
 *         description: Post khong ton tai
 */
router.get("/reports/post/:postId", protectedRoute, adminRoute, getReportsByPost);

/**
 * @swagger
 * /api/admin/posts/{postId}/hide:
 *   patch:
 *     summary: An (hide) 1 post va resolve cac reports lien quan
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reviewNote:
 *                 type: string
 *                 description: Ghi chu cua admin
 *     responses:
 *       200:
 *         description: An post thanh cong
 *       404:
 *         description: Post khong ton tai
 */
router.patch("/posts/:postId/hide", protectedRoute, adminRoute, hidePost);

/**
 * @swagger
 * /api/admin/posts/{postId}/restore:
 *   patch:
 *     summary: Restore post da bi an va dismiss cac reports lien quan
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reviewNote:
 *                 type: string
 *     responses:
 *       200:
 *         description: Restore thanh cong
 *       404:
 *         description: Post khong ton tai
 */
router.patch("/posts/:postId/restore", protectedRoute, adminRoute, restorePost);

/**
 * @swagger
 * /api/admin/posts/{postId}:
 *   delete:
 *     summary: Xoa han 1 post va resolve reports
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reviewNote:
 *                 type: string
 *     responses:
 *       200:
 *         description: Xoa post thanh cong
 *       404:
 *         description: Post khong ton tai
 */
router.delete("/posts/:postId", protectedRoute, adminRoute, deletePost);

/**
 * @swagger
 * /api/admin/reports/{reportId}:
 *   patch:
 *     summary: Review 1 report cu the (resolved/dismissed)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: reportId
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
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [resolved, dismissed]
 *               reviewNote:
 *                 type: string
 *     responses:
 *       200:
 *         description: Review thanh cong
 *       400:
 *         description: Status khong hop le
 *       404:
 *         description: Report khong ton tai
 */
router.patch("/reports/:reportId", protectedRoute, adminRoute, reviewReport);

export default router;
