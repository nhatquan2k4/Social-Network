import express from 'express';
import { authMe } from '../controller/userController';
import { protectedRoute } from '../middlewares/authMiddleware';

const router = express.Router();

router.get('/me', protectedRoute, authMe);

export default router;