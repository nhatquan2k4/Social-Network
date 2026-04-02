import { Request, Response } from 'express';
import { MessageService } from './messages.service';
import { MediaService } from '../media/media.service';

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

const mergeMediaFromRequest = async (req: Request, ownerId: string, conversationId?: string) => {
    const files = (req.files || []) as Express.Multer.File[];
    const uploadedMedia = files.length > 0
        ? await mediaService.uploadFiles(files, 'message', ownerId, { conversationId })
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

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: 'Thieu conversationId' });
        }

        const media = await mergeMediaFromRequest(req, senderId.toString(), String(conversationId));

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

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: 'Thieu conversationId' });
        }

        const media = await mergeMediaFromRequest(req, senderId.toString(), String(conversationId));

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

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: 'Thieu conversationId' });
        }

        const media = await mergeMediaFromRequest(req, senderId.toString(), String(conversationId));

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

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: 'Thieu conversationId' });
        }

        const media = await mergeMediaFromRequest(req, senderId.toString(), String(conversationId));

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

export const addOrUpdateMessageReaction = async (req: Request, res: Response) => {
    try {
        const { conversationId, messageId } = req.params;
        const { emoji } = req.body;
        const userId = req.user!._id;

        const data = await messageService.addOrUpdateReaction(
            conversationId as string,
            messageId as string,
            userId,
            String(emoji || ''),
        );

        return res.status(200).json({ message: 'Cap nhat reaction thanh cong', data });
    } catch (error: any) {
        console.error('Loi khi cap nhat reaction tin nhan', error);
        if (error?.name === 'CastError') {
            return res.status(400).json({ message: 'conversationId hoac messageId khong hop le' });
        }
        if (error.message === 'Emoji khong hop le') {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Tin nhan khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const removeMessageReaction = async (req: Request, res: Response) => {
    try {
        const { conversationId, messageId } = req.params;
        const userId = req.user!._id;

        const data = await messageService.removeReaction(
            conversationId as string,
            messageId as string,
            userId,
        );

        return res.status(200).json({ message: 'Da go reaction tin nhan', data });
    } catch (error: any) {
        console.error('Loi khi go reaction tin nhan', error);
        if (error?.name === 'CastError') {
            return res.status(400).json({ message: 'conversationId hoac messageId khong hop le' });
        }
        if (error.message === 'Tin nhan khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const markMessageAsRead = async (req: Request, res: Response) => {
    try {
        const { conversationId, messageId } = req.params;
        const userId = req.user!._id;

        const data = await messageService.markMessageAsRead(
            conversationId as string,
            messageId as string,
            userId,
        );

        return res.status(200).json({ message: 'Da danh dau tin nhan da doc', data });
    } catch (error: any) {
        console.error('Loi khi danh dau tin nhan da doc', error);
        if (error?.name === 'CastError') {
            return res.status(400).json({ message: 'conversationId hoac messageId khong hop le' });
        }
        if (error.message === 'Tin nhan khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const markMessagesAsReadBulk = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const userId = req.user!._id;
        const lastMessageIdRaw = req.body?.lastMessageId;
        const lastMessageId = typeof lastMessageIdRaw === 'string' && lastMessageIdRaw.trim()
            ? lastMessageIdRaw.trim()
            : undefined;

        const data = await messageService.markMessagesAsReadUntil(
            conversationId as string,
            userId,
            lastMessageId,
        );

        return res.status(200).json({ message: 'Da danh dau nhieu tin nhan da doc', data });
    } catch (error: any) {
        console.error('Loi khi danh dau nhieu tin nhan da doc', error);
        if (error?.name === 'CastError') {
            return res.status(400).json({ message: 'conversationId hoac lastMessageId khong hop le' });
        }
        if (error.message === 'Tin nhan khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};