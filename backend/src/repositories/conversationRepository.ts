import Conversation from '../models/conversation';
import { Types } from 'mongoose';

export class ConversationRepository {
    async findDirectConversation(userId: Types.ObjectId, participantId: Types.ObjectId) {
        return await Conversation.findOne({
            type: 'direct',
            'participants.userId': { $all: [userId, participantId] }
        });
    }

    async create(conversationData: any) {
        const conversation = new Conversation(conversationData);
        return await conversation.save();
    }

    async findById(conversationId: string) {
        return await Conversation.findById(conversationId);
    }

    async findByIdAndPopulate(conversationId: string) {
        return await Conversation.findById(conversationId)
            .populate([
                { path: 'participants.userId', select: 'displayName avatarUrl' },
                { path: 'seenBy', select: 'displayName avatarUrl' },
                { path: 'lastMessage.senderId', select: 'displayName avatarUrl' }
            ]);
    }

    async findByUserId(userId: Types.ObjectId) {
        return await Conversation.find({
            'participants.userId': userId
        })
        .sort({ lastMessageAt: -1, updatedAt: -1 })
        .populate({
            path: 'participants.userId',
            select: 'displayName avatarUrl'
        })
        .populate({
            path: 'lastMessage.senderId',
            select: 'displayName avatarUrl'
        })
        .populate({
            path: 'seenBy',
            select: 'displayName avatarUrl'
        });
    }

    async findUserConversationIds(userId: string | Types.ObjectId) {
        return await Conversation.find(
            { 'participants.userId': userId },
            { _id: 1 }
        );
    }

    async findByIdLean(conversationId: string) {
        return await Conversation.findById(conversationId).lean();
    }

    async updateMarkAsSeen(conversationId: string, userId: string) {
        return await Conversation.findByIdAndUpdate(
            conversationId,
            {
                $addToSet: { seenBy: userId },
                $set: { [`unreadCounts.${userId}`]: 0 }
            },
            { new: true }
        );
    }
}
