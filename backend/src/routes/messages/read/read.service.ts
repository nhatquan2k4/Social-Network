import { Types } from "mongoose";
import { MessageRepository } from "../shared/messages.repo";
import { MessageNotFoundError } from "../shared/messages.errors";
import { enrichMessageMedia } from "../shared/messages.util";
import {
    decodeMessageHistoryCursor,
    encodeMessageHistoryCursor,
    parseMessageHistoryLimit,
} from "./read.dto";

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

    async getConversationMessages(
        conversationId: string,
        rawLimit?: unknown,
        rawCursor?: unknown,
    ) {
        const limit = parseMessageHistoryLimit(rawLimit);
        const cursor = decodeMessageHistoryCursor(rawCursor);

        const rawMessages = await this.messageRepository.findByConversationId(conversationId, {
            limit: limit + 1,
            cursor,
        });

        const hasMore = rawMessages.length > limit;
        const pageMessages = hasMore ? rawMessages.slice(0, limit) : rawMessages;
        const messages = pageMessages.map((message) => enrichMessageMedia(message));

        const oldestMessage = pageMessages[pageMessages.length - 1];
        const nextCursor =
            hasMore && oldestMessage
                ? encodeMessageHistoryCursor(oldestMessage.createdAt, oldestMessage._id)
                : null;

        return {
            data: messages,
            pageInfo: {
                hasMore,
                limit,
                nextCursor,
            },
        };
    }
}
