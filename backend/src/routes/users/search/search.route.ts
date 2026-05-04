import express from 'express';
import { protectedRoute } from '../../../shared/middlewares/auth.middleware.js';
import { searchUsers } from './search.controller.js';

const router = express.Router();

/**
 * @swagger
 * /api/users/search:
 *   get:
 *     summary: Tim kiem user theo displayName
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Chuoi tim kiem theo displayName (bat buoc, khong duoc rong)
 *       - in: query
 *         name: page
 *         required: false
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Trang hien tai
 *       - in: query
 *         name: limit
 *         required: false
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 20
 *         description: So luong ket qua moi trang
 *     responses:
 *       200:
 *         description: Ket qua tim kiem
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
 *                       _id:
 *                         type: string
 *                       username:
 *                         type: string
 *                       displayName:
 *                         type: string
 *                       avatarUrl:
 *                         type: string
 *                         nullable: true
 *                       bio:
 *                         type: string
 *                         nullable: true
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *                     hasMore:
 *                       type: boolean
 *       400:
 *         description: name rong hoac khong hop le
 *       401:
 *         description: Chua xac thuc
 *       500:
 *         description: Loi server
 */
router.get('/search', protectedRoute, searchUsers);

export default router;
