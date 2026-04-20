import { Types } from "mongoose";
import { MessageRepository } from "../shared/messages.repo.js";
import { MessageNotFoundError } from "../shared/messages.errors.js";
import { enrichMessageMedia } from "../shared/messages.util.js";

export class ReadService {
    private messageRepository: MessageRepository;

    constructor() {
        this.messageRepository = new MessageRepository();
    }

    private async getMessageOrThrow(messageId: string, conversationId: string) {
        const message = await this.messageRepository.findByIdAndConversationId(
            messageId,
            conversationId,
        );

        if (!message) {
            throw new MessageNotFoundError();
        }

        return message;
    }

    async markMessageAsRead(
        conversationId: string,
        messageId: string,
        userId: Types.ObjectId,
    ) {
        await this.getMessageOrThrow(messageId, conversationId);

        const updated = await this.messageRepository.markAsRead(
            messageId,
            conversationId,
            userId,
        );

        if (!updated) {
            throw new MessageNotFoundError();
        }

        return enrichMessageMedia(updated);
    }

    async markMessagesAsReadUntil(
        conversationId: string,
        userId: Types.ObjectId,
        lastMessageId?: string,
    ) {
        let readUntil: Date | undefined;

        if (lastMessageId) {
            const targetMessage = await this.getMessageOrThrow(lastMessageId, conversationId);
            readUntil = (targetMessage as any).createdAt;
        }

        const result = await this.messageRepository.markAllAsReadByConversation(
            conversationId,
            userId,
            readUntil,
        );

        return {
            modifiedCount: result.modifiedCount,
            matchedCount: result.matchedCount,
            readUntil: readUntil ? readUntil.toISOString() : null,
        };
    }
}
