import { ConversationRepository } from '../conversations/conversations.repo';
import { MessageRepository } from './messages.repo';
import { Types } from 'mongoose';
import { updateConversationAfterCreateMessage } from '../../shared/utils/message.helper';
import { buildMediaUrl } from '../../shared/config/minio';

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

    private async getMessageOrThrow(messageId: string, conversationId: string) {
        const message = await this.messageRepository.findByIdAndConversationId(messageId, conversationId);
        if (!message) {
            throw new Error('Tin nhan khong ton tai');
        }
        return message;
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

    async addOrUpdateReaction(
        conversationId: string,
        messageId: string,
        userId: Types.ObjectId,
        emoji: string,
    ) {
        const normalizedEmoji = String(emoji || '').trim();
        if (!normalizedEmoji || normalizedEmoji.length > 32) {
            throw new Error('Emoji khong hop le');
        }

        await this.getMessageOrThrow(messageId, conversationId);

        const updated = await this.messageRepository.upsertReaction(
            messageId,
            conversationId,
            userId,
            normalizedEmoji,
        );

        if (!updated) {
            throw new Error('Tin nhan khong ton tai');
        }

        return this.enrichMessageMedia(updated);
    }

    async removeReaction(
        conversationId: string,
        messageId: string,
        userId: Types.ObjectId,
    ) {
        await this.getMessageOrThrow(messageId, conversationId);

        const updated = await this.messageRepository.removeReaction(
            messageId,
            conversationId,
            userId,
        );

        if (!updated) {
            throw new Error('Tin nhan khong ton tai');
        }

        return this.enrichMessageMedia(updated);
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
            throw new Error('Tin nhan khong ton tai');
        }

        return this.enrichMessageMedia(updated);
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
}
