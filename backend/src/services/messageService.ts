import { ConversationRepository } from '../repositories/conversationRepository';
import { MessageRepository } from '../repositories/messageRepository';
import { Types } from 'mongoose';
import { updateConversationAfterCreateMessage } from '../utils/messageHelper';

export class MessageService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
    }

    async sendDirectMessage(
        senderId: Types.ObjectId,
        recipientId: string,
        content: string,
        conversationId?: string
    ) {
        let conversation;

        if (conversationId) {
            // Tim conversation da ton tai
            conversation = await this.conversationRepository.findById(conversationId);
            if (!conversation) {
                // Tao moi neu khong co
                conversation = await this.conversationRepository.create({
                    type: 'direct',
                    participants: [
                        { userId: senderId, joinedAt: new Date() },
                        { userId: recipientId, joinedAt: new Date() }
                    ],
                    lastMessageAt: new Date(),
                    unreadCounts: new Map()
                });
            }
        } else {
            throw new Error('Thieu conversationId');
        }

        // Tao message
        const message = await this.messageRepository.create({
            conversationId: conversation._id,
            senderId,
            content
        });

        // Cap nhat conversation
        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return message;
    }

    async sendGroupMessage(
        senderId: Types.ObjectId,
        conversationId: string,
        content: string
    ) {
        const conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            throw new Error('Conversation khong ton tai');
        }

        // Tao message
        const message = await this.messageRepository.create({
            conversationId: conversation._id,
            senderId,
            content
        });

        // Cap nhat conversation
        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return message;
    }
}
