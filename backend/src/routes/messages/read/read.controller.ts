import { Request, Response } from "express";
import {
    MESSAGE_ERROR_MESSAGES,
    MESSAGE_SUCCESS_MESSAGES,
} from "../shared/messages.constants.js";
import { InvalidCursorError, MessageNotFoundError } from "../shared/messages.errors.js";
import { ReadService } from "./read.service.js";
import type { ReadServiceInterface } from "./read.service.interface.js";

const readService: ReadServiceInterface = new ReadService();

export const getConversationMessages = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;

        const result = await readService.getConversationMessages(
            conversationId as string,
            req.query.limit,
            req.query.cursor,
        );

        return res.status(200).json(result);
    } catch (error: any) {
        console.error("Loi khi lay lich su tin nhan conversation", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_IDS });
        }
        if (error instanceof InvalidCursorError) {
            return res.status(400).json({ message: error.message });
        }
        if (error instanceof Error && error.message === MESSAGE_ERROR_MESSAGES.INVALID_LIMIT) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const markMessageAsRead = async (req: Request, res: Response) => {
    try {
        const { conversationId, messageId } = req.params;
        const userId = req.user!._id;

        const data = await readService.markMessageAsRead(
            conversationId as string,
            messageId as string,
            userId,
        );

        return res.status(200).json({
            message: MESSAGE_SUCCESS_MESSAGES.READ_MARKED,
            data,
        });
    } catch (error: any) {
        console.error("Loi khi danh dau tin nhan da doc", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_IDS });
        }
        if (error instanceof MessageNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const markMessagesAsReadBulk = async (req: Request, res: Response) => {
    try {
        const { conversationId } = req.params;
        const userId = req.user!._id;
        const lastMessageIdRaw = req.body?.lastMessageId;
        const lastMessageId =
            typeof lastMessageIdRaw === "string" && lastMessageIdRaw.trim()
                ? lastMessageIdRaw.trim()
                : undefined;

        const data = await readService.markMessagesAsReadUntil(
            conversationId as string,
            userId,
            {
                displayName: (req.user as any).displayName ?? '',
                avatarUrl: (req.user as any).avatarUrl ?? '',
            },
            lastMessageId,
        );

        return res.status(200).json({
            message: MESSAGE_SUCCESS_MESSAGES.READ_BULK_MARKED,
            data,
        });
    } catch (error: any) {
        console.error("Loi khi danh dau nhieu tin nhan da doc", error);
        if (error?.name === "CastError") {
            return res.status(400).json({
                message: "conversationId hoac lastMessageId khong hop le",
            });
        }
        if (error instanceof MessageNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
