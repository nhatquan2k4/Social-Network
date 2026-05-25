import { Request, Response } from "express";
import {
    MESSAGE_ERROR_MESSAGES,
    MESSAGE_SUCCESS_MESSAGES,
} from "../shared/messages.constants.js";
import {
    ConversationAccessDeniedError,
    ConversationNotFoundError,
    InvalidEmojiError,
    MessageNotFoundError,
} from "../shared/messages.errors.js";
import { ReactionService } from "./reaction.service.js";
import type { ReactionServiceInterface } from "./reaction.service.interface.js";

const reactionService: ReactionServiceInterface = new ReactionService();

export const addOrUpdateMessageReaction = async (req: Request, res: Response) => {
    try {
        const { messageId } = req.params;
        const { emoji } = req.body;
        const userId = req.user!._id;

        const data = await reactionService.addOrUpdateReaction(
            messageId as string,
            userId,
            String(emoji || ""),
        );

        return res.status(200).json({
            message: MESSAGE_SUCCESS_MESSAGES.REACTION_UPDATED,
            data,
        });
    } catch (error: any) {
        console.error("Loi khi cap nhat reaction tin nhan", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_MESSAGE_ID });
        }
        if (error instanceof InvalidEmojiError) {
            return res.status(400).json({ message: error.message });
        }
        if (error instanceof ConversationAccessDeniedError) {
            return res.status(403).json({ message: error.message });
        }
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        if (error instanceof MessageNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const removeMessageReaction = async (req: Request, res: Response) => {
    try {
        const { messageId } = req.params;
        const userId = req.user!._id;

        const data = await reactionService.removeReaction(
            messageId as string,
            userId,
        );

        return res.status(200).json({
            message: MESSAGE_SUCCESS_MESSAGES.REACTION_REMOVED,
            data,
        });
    } catch (error: any) {
        console.error("Loi khi go reaction tin nhan", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_MESSAGE_ID });
        }
        if (error instanceof ConversationAccessDeniedError) {
            return res.status(403).json({ message: error.message });
        }
        if (error instanceof ConversationNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        if (error instanceof MessageNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
