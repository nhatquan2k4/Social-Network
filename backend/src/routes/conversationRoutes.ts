import express from 'express';
import {createConversation, getConversations, getMessages} from '../controller/conversationController';
import {protectedRoute} from '../middlewares/authMiddleware';
import {checkFriendship} from '../middlewares/friendMiddleware';

const router = express.Router();

router.post('/', protectedRoute, checkFriendship, createConversation);
router.get('/', protectedRoute, getConversations);
router.get('/:conversationId/messages', protectedRoute, checkFriendship, getMessages);

export default router;