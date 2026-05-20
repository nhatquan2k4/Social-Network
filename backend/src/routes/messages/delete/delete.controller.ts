import { Request, Response } from "express";
import {
    MESSAGE_ERROR_MESSAGES,
    MESSAGE_SUCCESS_MESSAGES,
} from "../shared/messages.constants.js";
import {
    ConversationAccessDeniedError,
    ConversationNotFoundError,
    MessageDeleteForbiddenError,
    MessageNotFoundError,
} from "../shared/messages.errors.js";
import { DeleteMessageService } from "./delete.service.js";
import type { DeleteMessageServiceInterface } from "./delete.service.interface.js";

const deleteMessageService: DeleteMessageServiceInterface = new DeleteMessageService();

export const deleteMessageForEveryone = async (req: Request, res: Response) => {
    try {
        const { conversationId, messageId } = req.params;
        const userId = req.user!._id;

        const data = await deleteMessageService.deleteForEveryone(
            conversationId as string,
            messageId as string,
            userId,
        );

        return res.status(200).json({
            message: MESSAGE_SUCCESS_MESSAGES.DELETED_FOR_EVERYONE,
            data,
        });
    } catch (error: any) {
        console.error("Loi khi go tin nhan", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: MESSAGE_ERROR_MESSAGES.INVALID_IDS });
        }
        if (error instanceof ConversationAccessDeniedError || error instanceof MessageDeleteForbiddenError) {
            return res.status(403).json({ message: error.message });
        }
        if (error instanceof ConversationNotFoundError || error instanceof MessageNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
