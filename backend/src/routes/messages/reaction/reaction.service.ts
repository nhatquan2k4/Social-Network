import { Types } from "mongoose";
import { emitMessageReaction } from "../../../shared/socket/socket.emitter.js";
import { ConversationRepository } from "../../conversations/shared/conversations.repo.js";
import { MessageRepository } from "../shared/messages.repo.js";
import {
    DEFAULT_REACTION_MAX_LENGTH,
} from "../shared/messages.constants.js";
import {
    ConversationAccessDeniedError,
    ConversationNotFoundError,
    InvalidEmojiError,
    MessageNotFoundError,
} from "../shared/messages.errors.js";
import { enrichMessageMedia } from "../shared/messages.util.js";
import type {
    ReactionConversationRepository,
    ReactionMessageRepository,
    ReactionServiceDependencies,
    ReactionServiceInterface,
} from "./reaction.service.interface.js";

export class ReactionService implements ReactionServiceInterface {
    private conversationRepository: ReactionConversationRepository;
    private messageRepository: ReactionMessageRepository;

    constructor(dependencies: ReactionServiceDependencies = {}) {
        this.conversationRepository =
            dependencies.conversationRepository ?? new ConversationRepository();
        this.messageRepository = dependencies.messageRepository ?? new MessageRepository();
    }

    private async resolveMessageContextOrThrow(messageId: string, userId: Types.ObjectId) {
        const message = await this.messageRepository.findById(messageId);

        if (!message) {
            throw new MessageNotFoundError();
        }

        const conversationId = String((message as any).conversationId || "");
        const conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            throw new ConversationNotFoundError();
        }

        const canAccess = (conversation.participants || []).some(
            (participant: any) => participant.userId.toString() === userId.toString(),
        );

        if (!canAccess) {
            throw new ConversationAccessDeniedError();
        }

        return { message, conversationId };
    }

    async addOrUpdateReaction(
        messageId: string,
        userId: Types.ObjectId,
        emoji: string,
    ) {
        const normalizedEmoji = String(emoji || "").trim();
        if (!normalizedEmoji || normalizedEmoji.length > DEFAULT_REACTION_MAX_LENGTH) {
            throw new InvalidEmojiError();
        }

        const { conversationId } = await this.resolveMessageContextOrThrow(messageId, userId);

        const updated = await this.messageRepository.upsertReaction(
            messageId,
            conversationId,
            userId,
            normalizedEmoji,
        );

        if (!updated) {
            throw new MessageNotFoundError();
        }

        const enriched = enrichMessageMedia(updated);

        const payload = {
            conversationId,
            messageId,
            reactions: (updated as any).reactions || [],
            updatedByUserId: userId.toString(),
            updatedAt: new Date().toISOString(),
        };

        emitMessageReaction(payload);

        return enriched;
    }

    async removeReaction(
        messageId: string,
        userId: Types.ObjectId,
    ) {
        const { conversationId } = await this.resolveMessageContextOrThrow(messageId, userId);

        const updated = await this.messageRepository.removeReaction(
            messageId,
            conversationId,
            userId,
        );

        if (!updated) {
            throw new MessageNotFoundError();
        }

        const enriched = enrichMessageMedia(updated);

        const payload = {
            conversationId,
            messageId,
            reactions: (updated as any).reactions || [],
            updatedByUserId: userId.toString(),
            updatedAt: new Date().toISOString(),
        };

        emitMessageReaction(payload);

        return enriched;
    }
}
