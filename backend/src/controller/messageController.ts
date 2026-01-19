import { Request, Response } from 'express';
import { MessageService } from '../services/messageService';

const messageService = new MessageService();

export const sendDirectMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, content, conversationId } = req.body;
        const senderId = req.user!._id;

        if (!content) {
            return res.status(400).json({ message: 'Thieu noi dung' });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId
        );

        return res.status(201).json({ message: 'Da gui tin nhan truc tiep', data: message });
    } catch (error: any) {
        console.error('Loi khi gui tin nhan truc tiep', error);
        if (error.message === 'Thieu conversationId') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const sendGroupMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!content) {
            return res.status(400).json({ message: 'Thiếu nội dung' });
        }

        const message = await messageService.sendGroupMessage(senderId, conversationId, content);

        return res.status(201).json({ message });
    } catch (error: any) {
        console.error('Lỗi xảy ra khi gửi tin nhắn nhóm', error);
        if (error.message === 'Conversation khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};