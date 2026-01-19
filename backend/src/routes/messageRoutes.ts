import express from 'express';
import { protectedRoute } from '../middlewares/authMiddleware';
import { checkFriendship, checkGroupMembership } from '../middlewares/friendMiddleware';
import {
    sendDirectMessage,
    sendGroupMessage
} from '../controller/messageController';


const router = express.Router();

router.post("/direct", protectedRoute, checkFriendship, sendDirectMessage);

router.post("/group", protectedRoute, checkGroupMembership, sendGroupMessage);

export default router;