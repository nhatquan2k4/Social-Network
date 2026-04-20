import { Request, Response } from "express";
import type { Types } from "mongoose";
import {
    CreateConversationRequest,
    GetConversationsQuery,
} from "./conversation.dto.js";
import { ConversationService } from "./conversation.service.js";
import {
    ConversationNotFoundError,
    ConversationTypeInvalidError,
    GroupLeaveOnlyError,
    GroupMemberNotFoundError,
} from "../shared/conversations.errors.js";
import { emitConversationSeen } from "../../../shared/socket/socket.emitter.js";

const conversationService = new ConversationService();

export const createConversation = async (req: Request, res: Response) => {
    try {
        const { type, name, memberIds, recipientId } = req.body as CreateConversationRequest;
        const userId = req.user!._id;

        if (type === "direct") {
            const targetId = recipientId || memberIds?.[0];
            if (!targetId) {
                return res.status(400).json({
                    message: "Can cung cap recipientId hoac memberIds cho direct conversation",
                });
            }

            const conversation = await conversationService.createConversation(
                userId,
                type,
                [targetId],
                name,
            );
            return res.status(201).json({ conversation });
        }

        if (type === "group") {
            if (!name || !memberIds || !Array.isArray(memberIds) || memberIds.length === 0) {
                return res.status(400).json({
                    message: "Ten nhom va danh sach thanh vien la bat buoc cho group conversation",
                });
            }

            const conversation = await conversationService.createConversation(
                userId,
                type,
                memberIds,
                name,
            );
            return res.status(201).json({ conversation });
        }

        return res.status(400).json({ message: "Type khong hop le" });
    } catch (error: any) {
        console.error("Loi khi tao conversation", error);
        if (error instanceof ConversationTypeInvalidError) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};

export const getConversations = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const { recipientId } = req.query as GetConversationsQuery;

        const conversations = await conversationService.getConversations(userId, recipientId);
        return res.status(200).json({ conversations });
    } catch (error) {
        console.error("Loi xay ra khi lay conversations", error);
        return res.status(500).json({ message: "Loi he thong" });
    }
};

export const getUserConversationsForSocketIO = async (userId: string | Types.ObjectId) => {
    return await conversationService.getUserConversationsForSocketIO(userId);
};

export const markAsSeen = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const userId = req.user!._id.toString();

        const result = await conversationService.markAsSeen(conversationId as string, userId);

        if ("seenBy" in result && "myUnreadCount" in result) {
            emitConversationSeen({
                conversationId: conversationId as string,
                userId,
                seenBy: result.seenBy,
                myUnreadCount: result.myUnreadCount,
            });
        }

        return res.status(200).json(result);
    } catch (error: any) {
        console.error("Loi khi mark as seen", error);
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};

export const leaveGroupConversation = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const userId = req.user!._id;

        const data = await conversationService.leaveGroupConversation(
            conversationId as string,
            userId,
        );

        return res.status(200).json({ message: "Roi nhom thanh cong", data });
    } catch (error: any) {
        console.error("Loi khi roi group conversation", error);
        if (error instanceof GroupLeaveOnlyError) {
            return res.status(400).json({ message: error.message });
        }
        if (error instanceof GroupMemberNotFoundError) {
            return res.status(403).json({ message: error.message });
        }
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};
