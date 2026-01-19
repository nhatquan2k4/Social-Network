import Conversation from '../models/conversation';
import Friend from '../models/friend';
import { Request, Response, NextFunction } from 'express';

// Helper function to ensure consistent ordering of user IDs
const pair = (userA: string, userB: string): [string, string] => {
    return userA < userB ? [userA, userB] : [userB, userA];
};

export const checkFriendship = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const me = req.user!._id.toString();

        const recipientId = req.body?.recipientId?? null;
        
        if (!recipientId) {
            return res.status(400).json({ message: 'Can cung cap recipientId' });
        }

        if (recipientId) {
            const [userA, userB] = pair(me, recipientId);

            const isFriend = await Friend.findOne({UserA : userA, UserB: userB});

            if (!isFriend) {
                return res.status(403).json({ message: 'Hai nguoi khong phai ban be' });
            }

            return next();
        }
    
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const checkGroupMembership = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { conversationId } = req.body;
    const userId = req.user!._id;

    const conversation = await Conversation.findById(conversationId);

    if (!conversation) {
      return res.status(404).json({ message: "Không tìm thấy cuộc trò chuyện" });
    }

    const isMember = conversation.participants.some(
      (p) => p.userId.toString() === userId.toString()
    );

    if (!isMember) {
      return res.status(403).json({ message: "Bạn không ở trong group này." });
    }

    req.conversation = conversation;

    next();
  } catch (error) {
    console.error("Lỗi checkGroupMembership:", error);
    return res.status(500).json({ message: "Lỗi hệ thống" });
  }
};