import { ConversationRepository } from '../repositories/conversationRepository';
import { MessageRepository } from '../repositories/messageRepository';
import { Types } from 'mongoose';
import { updateConversationAfterCreateMessage } from '../utils/messageHelper';
import { buildMediaUrl } from '../config/minio';

interface MessageMediaInput {
    bucket: string;
    objectKey: string;
    mimeType: string;
    size: number;
}

export class MessageService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
    }

    private sanitizeMedia(media?: MessageMediaInput[]) {
        if (!Array.isArray(media) || media.length === 0) {
            return undefined;
        }

        const cleaned = media
            .filter((item: any) => item && typeof item === 'object')
            .map((item: any) => ({
                bucket: typeof item.bucket === 'string' ? item.bucket.trim() : '',
                objectKey: typeof item.objectKey === 'string' ? item.objectKey.trim() : '',
                mimeType: typeof item.mimeType === 'string' ? item.mimeType.trim() : '',
                size: Number(item.size),
            }))
            .filter((item) => item.bucket && item.objectKey && item.mimeType && Number.isFinite(item.size) && item.size > 0);

        return cleaned.length > 0 ? cleaned : undefined;
    }

    private enrichMessageMedia(message: any) {
        const plain = typeof message.toObject === 'function' ? message.toObject() : message;

        const media = (plain.media || []).map((item: MessageMediaInput) => ({
            ...item,
            mediaUrl: buildMediaUrl(item.bucket, item.objectKey)
        }));

        if (media.length > 0) {
            return {
                ...plain,
                media,
            };
        }

        if (plain.imgUrl) {
            return {
                ...plain,
                media: [
                    {
                        bucket: '',
                        objectKey: '',
                        mimeType: 'image/*',
                        size: 0,
                        mediaUrl: plain.imgUrl,
                    },
                ],
            };
        }

        return plain;
    }

    async sendDirectMessage(
        senderId: Types.ObjectId,
        recipientId: string,
        content?: string,
        conversationId?: string,
        media?: MessageMediaInput[]
    ) {
        const safeMedia = this.sanitizeMedia(media);

        if (!content && !safeMedia) {
            throw new Error('Thieu noi dung hoac media');
        }

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
            content,
            media: safeMedia,
        });

        // Cap nhat conversation
        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return this.enrichMessageMedia(message);
    }

    async sendGroupMessage(
        senderId: Types.ObjectId,
        conversationId: string,
        content?: string,
        media?: MessageMediaInput[]
    ) {
        const safeMedia = this.sanitizeMedia(media);

        if (!content && !safeMedia) {
            throw new Error('Thieu noi dung hoac media');
        }

        const conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            throw new Error('Conversation khong ton tai');
        }

        // Tao message
        const message = await this.messageRepository.create({
            conversationId: conversation._id,
            senderId,
            content,
            media: safeMedia,
        });

        // Cap nhat conversation
        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return this.enrichMessageMedia(message);
    }
}
