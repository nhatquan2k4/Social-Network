import express from 'express';
import { protectedRoute } from '../../../shared/middlewares/auth.middleware.js';
import { getUserPosts } from './user-posts.controller.js';

const router = express.Router();

/**
 * @swagger
 * /api/users/{userId}/posts:
 *   get:
 *     summary: Lay danh sach post cua user
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Danh sach post cua user
 */
router.get('/:userId/posts', protectedRoute, getUserPosts);

export default router;
