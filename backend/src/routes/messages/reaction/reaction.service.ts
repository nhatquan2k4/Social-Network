import { Types } from "mongoose";
import { ConversationRepository } from "../../conversations/shared/conversations.repo";
import { MessageRepository } from "../shared/messages.repo";
import {
    DEFAULT_REACTION_MAX_LENGTH,
} from "../shared/messages.constants";
import {
    ConversationAccessDeniedError,
    ConversationNotFoundError,
    InvalidEmojiError,
    MessageNotFoundError,
} from "../shared/messages.errors";
import { enrichMessageMedia } from "../shared/messages.util";

export class ReactionService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
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

        return enrichMessageMedia(updated);
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

        return enrichMessageMedia(updated);
    }
}
