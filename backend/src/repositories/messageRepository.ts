import Message from '../models/message';
import { Types } from 'mongoose';

export class MessageRepository {
    async create(messageData: {
        conversationId: Types.ObjectId;
        senderId: Types.ObjectId;
        content: string;
    }) {
        return await Message.create(messageData);
    }

    async findByConversationId(conversationId: string, query: any, limit: number) {
        return await Message.find(query)
            .sort({ createdAt: -1 })
            .limit(limit);
    }
}
