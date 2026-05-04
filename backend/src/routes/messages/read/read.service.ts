import { Types } from "mongoose";
import { MessageRepository } from "../shared/messages.repo.js";
import { MessageNotFoundError } from "../shared/messages.errors.js";
import { enrichMessageMedia } from "../shared/messages.util.js";
import {
    decodeMessageHistoryCursor,
    encodeMessageHistoryCursor,
    parseMessageHistoryLimit,
} from "./read.dto.js";
import { ConversationRepository } from "../../conversations/shared/conversations.repo.js";
import { emitMessageSeen } from "../../../shared/socket/socket.emitter.js";

export class ReadService {
    private messageRepository: MessageRepository;
    private conversationRepository: ConversationRepository;

    constructor() {
        this.messageRepository = new MessageRepository();
        this.conversationRepository = new ConversationRepository();
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

        // Phase 4: sync unreadCount = 0 cho user này ở conversation
        await this.conversationRepository.updateMarkAsSeen(conversationId, userId.toString());

        // Phase 3: emit realtime sau khi DB save thành công
        emitMessageSeen({
            conversationId,
            seenByUserId: userId.toString(),
            seenAt: new Date().toISOString(),
        });

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
