import Conversation from '../models/conversation';
import Friend from '../models/friend';
import { Request, Response, NextFunction } from 'express';

// Helper function to ensure consistent ordering of user IDs
const pair = (userA: string, userB: string): [string, string] => {
    return userA < userB ? [userA, userB] : [userB, userA];
};

export const checkFriendship = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const me = req.user!._id.toString();

    // Bỏ qua kiểm tra friendship cho group conversation
    if (req.body?.type === "group") {
      return next();
    }

    // Lấy recipientId từ body, query, hoặc memberIds[0] nếu type là direct
    let recipientId = req.body?.recipientId ?? req.query?.recipientId ?? null;

    // Nếu không có recipientId nhưng có memberIds và type là direct
    if (
      !recipientId &&
      req.body?.type === "direct" &&
      req.body?.memberIds?.[0]
    ) {
      recipientId = req.body.memberIds[0];
    }

    if (!recipientId) {
      return res
        .status(400)
        .json({ message: "Can cung cap recipientId hoac memberIds" });
    }

    if (recipientId) {
      const [userA, userB] = pair(me, recipientId as string);

      const isFriend = await Friend.findOne({ userA: userA, userB: userB });

      if (!isFriend) {
        return res.status(403).json({ message: "Hai nguoi khong phai ban be" });
      }

      return next();
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Loi server" });
  }
};

export const checkGroupMembership = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { conversationId } = req.body;
    const userId = req.user!._id;

    const conversation = await Conversation.findById(conversationId);

    if (!conversation) {
      return res
        .status(404)
        .json({ message: "Không tìm thấy cuộc trò chuyện" });
    }

    const isMember = conversation.participants.some(
      (p) => p.userId.toString() === userId.toString(),
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

export const checkConversationMembership = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Lấy conversationId từ params hoặc body
    const conversationId = req.params.conversationId || req.body.conversationId;
    const userId = req.user!._id;

    if (!conversationId) {
      return res.status(400).json({ message: "Thiếu conversationId" });
    }

    const conversation = await Conversation.findById(conversationId);

    if (!conversation) {
      return res
        .status(404)
        .json({ message: "Không tìm thấy cuộc trò chuyện" });
    }

    const isMember = conversation.participants.some(
      (p) => p.userId.toString() === userId.toString(),
    );

    if (!isMember) {
      return res
        .status(403)
        .json({ message: "Bạn không có quyền truy cập cuộc trò chuyện này" });
    }

    req.conversation = conversation;
    next();
  } catch (error) {
    console.error("Lỗi checkConversationMembership:", error);
    return res.status(500).json({ message: "Lỗi hệ thống" });
  }
};