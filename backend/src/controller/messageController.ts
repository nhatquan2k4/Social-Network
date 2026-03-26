import { Request, Response } from 'express';
import { MessageService } from '../services/messageService';
import { MediaService } from '../services/mediaService';

const messageService = new MessageService();
const mediaService = new MediaService();

const parseManualMedia = (raw: any) => {
    if (!raw) {
        return [];
    }

    let value = raw;
    if (typeof raw === 'string') {
        try {
            value = JSON.parse(raw);
        } catch {
            return [];
        }
    }

    if (!Array.isArray(value)) {
        return [];
    }

    return value
        .filter((item: any) => item && typeof item === 'object')
        .map((item: any) => ({
            bucket: typeof item.bucket === 'string' ? item.bucket.trim() : '',
            objectKey: typeof item.objectKey === 'string' ? item.objectKey.trim() : '',
            mimeType: typeof item.mimeType === 'string' ? item.mimeType.trim() : '',
            size: Number(item.size),
        }))
        .filter((item: any) => item.bucket && item.objectKey && item.mimeType && Number.isFinite(item.size) && item.size > 0);
};

const mergeMediaFromRequest = async (req: Request, ownerId: string) => {
    const files = (req.files || []) as Express.Multer.File[];
    const uploadedMedia = files.length > 0
        ? await mediaService.uploadFiles(files, 'message', ownerId)
        : [];

    const normalizedUploaded = uploadedMedia.map((item) => ({
        bucket: item.bucket,
        objectKey: item.objectKey,
        mimeType: item.mimeType,
        size: item.size,
    }));

    const manualMedia = parseManualMedia(req.body?.media);

    return [...manualMedia, ...normalizedUploaded];
};

export const sendDirectTextMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, content, conversationId } = req.body;
        const senderId = req.user!._id;

        if (!content || !String(content).trim()) {
            return res.status(400).json({ message: 'Thieu noi dung' });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            undefined,
        );

        return res.status(201).json({ message: 'Da gui tin nhan truc tiep', data: message });
    } catch (error: any) {
        console.error('Loi khi gui tin nhan truc tiep (text)', error);
        if (error.message === 'Thieu conversationId') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const sendDirectMediaMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, conversationId, content } = req.body;
        const senderId = req.user!._id;
        const media = await mergeMediaFromRequest(req, senderId.toString());

        if (!Array.isArray(media) || media.length === 0) {
            return res.status(400).json({ message: 'Thieu media hop le' });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            media,
        );

        return res.status(201).json({ message: 'Da gui anh truc tiep', data: message });
    } catch (error: any) {
        console.error('Loi khi gui tin nhan truc tiep (media)', error);
        if (error.message === 'Thieu conversationId') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const sendGroupTextMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!content || !String(content).trim()) {
            return res.status(400).json({ message: 'Thiếu nội dung' });
        }

        const message = await messageService.sendGroupMessage(senderId, conversationId, content, undefined);

        return res.status(201).json({ message, data: message });
    } catch (error: any) {
        console.error('Lỗi xảy ra khi gửi tin nhắn nhóm (text)', error);
        if (error.message === 'Conversation khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const sendGroupMediaMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;
        const media = await mergeMediaFromRequest(req, senderId.toString());

        if (!Array.isArray(media) || media.length === 0) {
            return res.status(400).json({ message: 'Thieu media hop le' });
        }

        const message = await messageService.sendGroupMessage(senderId, conversationId, content, media);

        return res.status(201).json({ message, data: message });
    } catch (error: any) {
        console.error('Lỗi xảy ra khi gửi tin nhắn nhóm (media)', error);
        if (error.message === 'Conversation khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const sendDirectMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, content, conversationId } = req.body;
        const senderId = req.user!._id;

        const media = await mergeMediaFromRequest(req, senderId.toString());

        if (!content && (!Array.isArray(media) || media.length === 0)) {
            return res.status(400).json({ message: 'Thieu noi dung hoac media' });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            media
        );

        return res.status(201).json({ message: 'Da gui tin nhan truc tiep', data: message });
    } catch (error: any) {
        console.error('Loi khi gui tin nhan truc tiep', error);
        if (error.message === 'Thieu noi dung hoac media') {
            return res.status(400).json({ message: error.message });
        }
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

        const media = await mergeMediaFromRequest(req, senderId.toString());

        if (!content && (!Array.isArray(media) || media.length === 0)) {
            return res.status(400).json({ message: 'Thiếu nội dung hoặc media' });
        }

        const message = await messageService.sendGroupMessage(senderId, conversationId, content, media);

        return res.status(201).json({ message });
    } catch (error: any) {
        console.error('Lỗi xảy ra khi gửi tin nhắn nhóm', error);
        if (error.message === 'Thieu noi dung hoac media') {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Conversation khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};