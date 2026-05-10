import { Types } from "mongoose";
import { emitMessageDeleted } from "../../../shared/socket/socket.emitter.js";
import { ConversationRepository } from "../../conversations/shared/conversations.repo.js";
import { MessageRepository } from "../shared/messages.repo.js";
import {
    ConversationAccessDeniedError,
    ConversationNotFoundError,
    MessageDeleteForbiddenError,
    MessageNotFoundError,
} from "../shared/messages.errors.js";

export class DeleteMessageService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
    }

    private isParticipant(conversation: any, userId: Types.ObjectId) {
        return (conversation.participants || []).some(
            (participant: any) => participant.userId.toString() === userId.toString(),
        );
    }

    private buildLastMessage(message: any) {
        if (!message) {
            return null;
        }

        const fallbackContent =
            message.content ||
            (Array.isArray(message.media) && message.media.length > 0 ? "[Image]" : null);

        return {
            _id: message._id,
            content: fallbackContent,
            senderId: message.senderId,
            createdAt: message.createdAt,
        };
    }

    private syncUnreadCountsAfterDelete(conversation: any, message: any) {
        const senderId = message.senderId._id
            ? message.senderId._id.toString()
            : message.senderId.toString();
        const readBy = new Set(
            (message.readBy || []).map((reader: any) => reader.userId.toString()),
        );

        (conversation.participants || []).forEach((participant: any) => {
            const memberId = participant.userId.toString();
            if (memberId === senderId || readBy.has(memberId)) {
                return;
            }

            const current = conversation.unreadCounts?.get(memberId) || 0;
            conversation.unreadCounts.set(memberId, Math.max(0, current - 1));
        });
    }

    async deleteForEveryone(
        conversationId: string,
        messageId: string,
        requesterId: Types.ObjectId,
    ) {
        const [conversation, message] = await Promise.all([
            this.conversationRepository.findById(conversationId),
            this.messageRepository.findByIdAndConversationId(messageId, conversationId),
        ]);

        if (!conversation) {
            throw new ConversationNotFoundError();
        }

        if (!message) {
            throw new MessageNotFoundError();
        }

        if (!this.isParticipant(conversation, requesterId)) {
            throw new ConversationAccessDeniedError();
        }

        const senderIdStr = (message as any).senderId._id
            ? (message as any).senderId._id.toString()
            : (message as any).senderId.toString();

        if (senderIdStr !== requesterId.toString()) {
            throw new MessageDeleteForbiddenError();
        }

        await this.messageRepository.deleteByIdAndConversationId(messageId, conversationId);

        const latestMessage = await this.messageRepository.findLatestByConversationId(
            conversationId,
        );

        conversation.set({
            lastMessage: this.buildLastMessage(latestMessage),
            lastMessageAt: latestMessage ? (latestMessage as any).createdAt : null,
        });
        this.syncUnreadCountsAfterDelete(conversation, message);
        await conversation.save();

        const payload = {
            conversationId,
            messageId,
            deletedByUserId: requesterId.toString(),
            deletedAt: new Date().toISOString(),
        };

        emitMessageDeleted(payload);

        return payload;
    }
}
