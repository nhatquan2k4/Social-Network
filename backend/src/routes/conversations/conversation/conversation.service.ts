import { Types } from "mongoose";
import { MessageRepository } from "../../messages/shared/messages.repo.js";
import { ConversationRepository } from "../shared/conversations.repo.js";
import {
    CONVERSATION_ERROR_MESSAGES,
    CONVERSATION_TYPES,
} from "../shared/conversations.constants.js";
import {
    ConversationNotFoundError,
    ConversationTypeInvalidError,
    GroupLeaveOnlyError,
    GroupMemberNotFoundError,
    GroupOwnerNotFoundError,
} from "../shared/conversations.errors.js";
import { mapConversationParticipants } from "../shared/conversations.util.js";

export class ConversationService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
    }

    async createConversation(
        userId: Types.ObjectId,
        type: string,
        memberIds: string[],
        name?: string,
    ) {
        let conversation;

        if (type === CONVERSATION_TYPES.DIRECT) {
            const participantId = memberIds[0];

            conversation = await this.conversationRepository.findDirectConversation(
                userId,
                participantId as any,
            );

            if (!conversation) {
                conversation = await this.conversationRepository.create({
                    type: CONVERSATION_TYPES.DIRECT,
                    participants: [{ userId }, { userId: participantId }],
                    lastMessageAt: new Date(),
                });
            }
        } else if (type === CONVERSATION_TYPES.GROUP) {
            conversation = await this.conversationRepository.create({
                type: CONVERSATION_TYPES.GROUP,
                participants: [{ userId }, ...memberIds.map((id) => ({ userId: id }))],
                group: {
                    name,
                    createdBy: userId,
                },
                lastMessageAt: new Date(),
            });
        } else {
            throw new ConversationTypeInvalidError();
        }

        await conversation.populate([
            { path: "participants.userId", select: "displayName avatarUrl" },
            { path: "seenBy", select: "displayName avatarUrl" },
            { path: "lastMessage.senderId", select: "displayName avatarUrl" },
        ]);

        return {
            ...conversation.toObject(),
            participants: mapConversationParticipants(conversation.participants || []),
        };
    }

    async getConversations(userId: Types.ObjectId, recipientId?: string) {
        let conversations;

        if (recipientId) {
            const conversation = await this.conversationRepository.findDirectConversation(
                userId,
                recipientId as any,
            );
            conversations = conversation ? [conversation] : [];
        } else {
            conversations = await this.conversationRepository.findByUserId(userId);
        }

        return conversations.map((conversation: any) => ({
            ...conversation.toObject(),
            unreadCounts: conversation.unreadCounts || {},
            participants: mapConversationParticipants(conversation.participants || []),
        }));
    }

    async getUserConversationsForSocketIO(userId: string | Types.ObjectId) {
        try {
            const conversations =
                await this.conversationRepository.findUserConversationIds(userId);
            return conversations.map((conversation: any) => conversation._id.toString());
        } catch (error) {
            console.error("Loi khi fetch conversations:", error);
            return [];
        }
    }

    async markAsSeen(conversationId: string, userId: string) {
        const conversation = await this.conversationRepository.findByIdLean(conversationId);

        if (!conversation) {
            throw new ConversationNotFoundError();
        }

        const lastMessage = conversation.lastMessage;

        if (!lastMessage) {
            return { message: "Khong co tin nhan de mark as seen" };
        }

        if (!lastMessage.senderId || lastMessage.senderId.toString() === userId) {
            return { message: "Sender khong can mark as seen" };
        }

        const updated = await this.conversationRepository.updateMarkAsSeen(
            conversationId,
            userId,
        );

        return {
            message: "Marked as seen",
            seenBy: updated?.seenBy || [],
            myUnreadCount: updated?.unreadCounts?.get(userId) || 0,
        };
    }

    async leaveGroupConversation(conversationId: string, userId: Types.ObjectId) {
        const conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            throw new ConversationNotFoundError();
        }

        if (conversation.type !== CONVERSATION_TYPES.GROUP) {
            throw new GroupLeaveOnlyError();
        }

        const me = userId.toString();
        const isMember = (conversation.participants || []).some(
            (participant: any) => participant.userId.toString() === me,
        );

        if (!isMember) {
            throw new GroupMemberNotFoundError();
        }

        conversation.participants = (conversation.participants || []).filter(
            (participant: any) => participant.userId.toString() !== me,
        ) as any;

        conversation.seenBy = (conversation.seenBy || []).filter(
            (reader: any) => reader.toString() !== me,
        ) as any;

        if (
            conversation.unreadCounts &&
            typeof conversation.unreadCounts.delete === "function"
        ) {
            conversation.unreadCounts.delete(me);
        }

        const ownerId = conversation.group?.createdBy?.toString();
        const isOwnerLeaving = ownerId === me;
        const remainedParticipants = conversation.participants || [];

        if (remainedParticipants.length === 0) {
            await Promise.all([
                this.conversationRepository.deleteById(conversationId),
                this.messageRepository.deleteByConversationId(conversationId),
            ]);

            return {
                action: "conversation_deleted",
                conversationId,
            };
        }

        let newOwnerId: string | null = null;

        if (isOwnerLeaving && conversation.group) {
            const sortedParticipants = [...remainedParticipants].sort((a: any, b: any) => {
                const aTime = a.joinedAt ? new Date(a.joinedAt).getTime() : 0;
                const bTime = b.joinedAt ? new Date(b.joinedAt).getTime() : 0;
                return aTime - bTime;
            });

            const newOwner = sortedParticipants[0];
            if (!newOwner) {
                throw new GroupOwnerNotFoundError();
            }

            conversation.group.createdBy = newOwner.userId;
            newOwnerId = newOwner.userId.toString();
        }

        await conversation.save();

        return {
            action: newOwnerId ? "owner_transferred" : "left",
            conversationId,
            newOwnerId,
            participantsCount: remainedParticipants.length,
        };
    }
}
