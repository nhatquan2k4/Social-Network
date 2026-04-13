import { Types } from "mongoose";
import { ConversationRepository } from "../../conversations/shared/conversations.repo";
import { updateConversationAfterCreateMessage } from "../../../shared/utils/message.helper";
import { MessageRepository } from "../shared/messages.repo";
import {
    ConversationNotFoundError,
    MissingContentOrMediaError,
    MissingConversationIdError,
} from "../shared/messages.errors";
import { enrichMessageMedia, sanitizeMedia } from "../shared/messages.util";
import { MessageMediaInput } from "./message.dto";

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
        content?: string,
        conversationId?: string,
        media?: MessageMediaInput[],
    ) {
        const safeMedia = sanitizeMedia(media);

        if (!content && !safeMedia) {
            throw new MissingContentOrMediaError();
        }

        if (!conversationId) {
            throw new MissingConversationIdError();
        }

        let conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            conversation = await this.conversationRepository.create({
                type: "direct",
                participants: [
                    { userId: senderId, joinedAt: new Date() },
                    { userId: recipientId, joinedAt: new Date() },
                ],
                lastMessageAt: new Date(),
                unreadCounts: new Map(),
            });
        }

        const message = await this.messageRepository.create({
            conversationId: conversation._id,
            senderId,
            content,
            media: safeMedia,
        });

        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return enrichMessageMedia(message);
    }

    async sendGroupMessage(
        senderId: Types.ObjectId,
        conversationId: string,
        content?: string,
        media?: MessageMediaInput[],
    ) {
        const safeMedia = sanitizeMedia(media);

        if (!content && !safeMedia) {
            throw new MissingContentOrMediaError();
        }

        const conversation = await this.conversationRepository.findById(conversationId);

        if (!conversation) {
            throw new ConversationNotFoundError();
        }

        const message = await this.messageRepository.create({
            conversationId: conversation._id,
            senderId,
            content,
            media: safeMedia,
        });

        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        return enrichMessageMedia(message);
    }
}
