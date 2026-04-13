import { Request, Response } from "express";
import {
    MESSAGE_ERROR_MESSAGES,
    MESSAGE_SUCCESS_MESSAGES,
} from "../shared/messages.constants";
import {
    ConversationNotFoundError,
    MissingContentOrMediaError,
    MissingConversationIdError,
} from "../shared/messages.errors";
import { mergeMediaFromRequest } from "../shared/messages.util";
import { MessageService } from "./message.service";

const messageService = new MessageService();

export const sendDirectTextMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, content, conversationId } = req.body;
        const senderId = req.user!._id;

        if (!content || !String(content).trim()) {
            return res.status(400).json({ message: "Thieu noi dung" });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            undefined,
        );

        return res.status(201).json({
            message: MESSAGE_SUCCESS_MESSAGES.SENT_DIRECT,
            data: message,
        });
    } catch (error: any) {
        console.error("Loi khi gui tin nhan truc tiep (text)", error);
        if (error instanceof MissingConversationIdError) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const sendDirectMediaMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONVERSATION_ID });
        }

        const media = await mergeMediaFromRequest(
            req,
            senderId.toString(),
            String(conversationId),
        );

        if (!Array.isArray(media) || media.length === 0) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_MEDIA });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            media,
        );

        return res.status(201).json({
            message: MESSAGE_SUCCESS_MESSAGES.SENT_DIRECT_MEDIA,
            data: message,
        });
    } catch (error: any) {
        console.error("Loi khi gui tin nhan truc tiep (media)", error);
        if (error instanceof MissingConversationIdError) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const sendGroupTextMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!content || !String(content).trim()) {
            return res.status(400).json({ message: "Thieu noi dung" });
        }

        const message = await messageService.sendGroupMessage(
            senderId,
            conversationId,
            content,
            undefined,
        );

        return res.status(201).json({ message, data: message });
    } catch (error: any) {
        console.error("Loi xay ra khi gui tin nhan nhom (text)", error);
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};

export const sendGroupMediaMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONVERSATION_ID });
        }

        const media = await mergeMediaFromRequest(
            req,
            senderId.toString(),
            String(conversationId),
        );

        if (!Array.isArray(media) || media.length === 0) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_MEDIA });
        }

        const message = await messageService.sendGroupMessage(
            senderId,
            conversationId,
            content,
            media,
        );

        return res.status(201).json({
            message: MESSAGE_SUCCESS_MESSAGES.SENT_GROUP_MEDIA,
            data: message,
        });
    } catch (error: any) {
        console.error("Loi xay ra khi gui tin nhan nhom (media)", error);
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};

export const sendDirectMessage = async (req: Request, res: Response) => {
    try {
        const { recipientId, content, conversationId } = req.body;
        const senderId = req.user!._id;

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONVERSATION_ID });
        }

        const media = await mergeMediaFromRequest(
            req,
            senderId.toString(),
            String(conversationId),
        );

        if (!content && (!Array.isArray(media) || media.length === 0)) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONTENT_OR_MEDIA });
        }

        const message = await messageService.sendDirectMessage(
            senderId,
            recipientId,
            content,
            conversationId,
            media,
        );

        return res.status(201).json({
            message: MESSAGE_SUCCESS_MESSAGES.SENT_DIRECT,
            data: message,
        });
    } catch (error: any) {
        console.error("Loi khi gui tin nhan truc tiep", error);
        if (error instanceof MissingContentOrMediaError || error instanceof MissingConversationIdError) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const sendGroupMessage = async (req: Request, res: Response) => {
    try {
        const { conversationId, content } = req.body;
        const senderId = req.user!._id;

        if (!conversationId || !String(conversationId).trim()) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONVERSATION_ID });
        }

        const media = await mergeMediaFromRequest(
            req,
            senderId.toString(),
            String(conversationId),
        );

        if (!content && (!Array.isArray(media) || media.length === 0)) {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.MISSING_CONTENT_OR_MEDIA });
        }

        const message = await messageService.sendGroupMessage(
            senderId,
            conversationId,
            content,
            media,
        );

        return res.status(201).json({ message });
    } catch (error: any) {
        console.error("Loi xay ra khi gui tin nhan nhom", error);
        if (error instanceof MissingContentOrMediaError) {
            return res.status(400).json({ message: error.message });
        }
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi he thong" });
    }
};
