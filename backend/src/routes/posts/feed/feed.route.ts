import express from "express";
import { protectedRoute } from "../../../shared/middlewares/auth.middleware.js";
import { getFeed } from "./feed.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/posts/feed:
 *   get:
 *     summary: Lay feed bai viet
 *     tags: [Posts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
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
 *         description: Feed bai viet
 */
router.get("/feed", protectedRoute, getFeed);

export default router;
