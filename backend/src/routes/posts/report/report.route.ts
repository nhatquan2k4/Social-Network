import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { reportPost } from "./report.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/posts/{postId}/report:
 *   post:
 *     summary: Report mot bai viet vi pham
 *     description: |
 *       Gui report cho bai viet. Moi user chi duoc report 1 post 1 lan.
 *       Khong the report bai viet cua chinh minh.
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: postId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID cua bai viet can report
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reason
 *             properties:
 *               reason:
 *                 type: string
 *                 enum:
 *                   - spam
 *                   - harassment
 *                   - hate_speech
 *                   - violence
 *                   - nudity
 *                   - false_information
 *                   - other
 *                 description: Ly do report
 *               description:
 *                 type: string
 *                 maxLength: 1000
 *                 description: Mo ta chi tiet (tuy chon)
 *     responses:
 *       201:
 *         description: Report thanh cong
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     reportId:
 *                       type: string
 *                     postId:
 *                       type: string
 *                     reason:
 *                       type: string
 *                     description:
 *                       type: string
 *                       nullable: true
 *                     reportCount:
 *                       type: integer
 *                       description: Tong so report cua post nay
 *                     createdAt:
 *                       type: string
 *                       format: date-time
 *       400:
 *         description: Ly do khong hop le hoac report bai cua chinh minh
 *       404:
 *         description: Post khong ton tai
 *       409:
 *         description: Da report bai viet nay roi
 *       401:
 *         description: Chua xac thuc
 */
router.post("/:postId/report", protectedRoute, reportPost);

export default router;
