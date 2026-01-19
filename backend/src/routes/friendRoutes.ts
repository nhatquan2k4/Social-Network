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

router.post("/requests", protectedRoute, sendFriendRequest);

router.post("/requests/:requestId/accept", protectedRoute, acceptFriendRequest);

router.post("/requests/:requestId/reject", protectedRoute, rejectFriendRequest);

router.get("/", protectedRoute, getAllFriend);

router.get("/requests", protectedRoute, getAllFriendRequest);

export default router;