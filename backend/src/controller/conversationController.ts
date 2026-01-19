import { Request, Response } from 'express';
import { ConversationService } from '../services/conversationService';
import type { Types } from 'mongoose';

const conversationService = new ConversationService();

export const createConversation = async (req: Request, res: Response) => {
    try {
        const { type, name, memberIds } = req.body;
        const userId = req.user!._id;

        if (
            !type ||
            (type === 'group' && !name) ||
            !memberIds ||
            !Array.isArray(memberIds) ||
            memberIds.length === 0
        ) {
            return res
                .status(400)
                .json({ message: 'Tên nhóm và danh sách thành viên là bắt buộc' });
        }

        const conversation = await conversationService.createConversation(
            userId,
            type,
            memberIds,
            name
        );

        return res.status(201).json({ conversation });
    } catch (error: any) {
        console.error('Lỗi khi tạo conversation', error);
        if (error.message === 'Conversation type khong hop le') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const getConversations = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;

        const conversations = await conversationService.getConversations(userId);

        return res.status(200).json({ conversations });
    } catch (error) {
        console.error('Lỗi xảy ra khi lấy conversations', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const getMessages = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const { limit = 50, cursor } = req.query;

        const result = await conversationService.getMessages(
            conversationId as string,
            Number(limit),
            cursor as string | undefined
        );

        return res.status(200).json(result);
    } catch (error) {
        console.error('Lỗi xảy ra khi lấy messages', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
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

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Lỗi khi mark as seen', error);
        if (error.message === 'Conversation khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};
