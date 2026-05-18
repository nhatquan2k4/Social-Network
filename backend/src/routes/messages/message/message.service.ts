import { Types } from "mongoose";
import { ConversationRepository } from "../../conversations/shared/conversations.repo.js";
import { updateConversationAfterCreateMessage } from "../../../shared/utils/message.helper.js";
import { MessageRepository } from "../shared/messages.repo.js";
import { emitMessageNew } from "../../../shared/socket/socket.emitter.js";
import { NotificationService } from "../../notifications/notifications.service.js";
import {
    ConversationNotFoundError,
    MissingContentOrMediaError,
    MissingConversationIdError,
} from "../shared/messages.errors.js";
import { enrichMessageMedia, sanitizeMedia } from "../shared/messages.util.js";
import { MessageMediaInput } from "./message.dto.js";

export class MessageService {
    private conversationRepository: ConversationRepository;
    private messageRepository: MessageRepository;
    private notificationService: NotificationService;

    constructor() {
        this.conversationRepository = new ConversationRepository();
        this.messageRepository = new MessageRepository();
        this.notificationService = new NotificationService();
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

        await message.populate("senderId", "displayName avatarUrl username");

        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        emitMessageNew(conversation._id.toString(), enrichMessageMedia(message));
        await this.notifyMessageRecipients(conversation, senderId, message);

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

        await message.populate("senderId", "displayName avatarUrl username");

        await updateConversationAfterCreateMessage(conversation, message, senderId);
        await conversation.save();

        emitMessageNew(conversation._id.toString(), enrichMessageMedia(message));
        await this.notifyMessageRecipients(conversation, senderId, message);

        return enrichMessageMedia(message);
    }

    private async notifyMessageRecipients(conversation: any, senderId: Types.ObjectId, message: any) {
        const participants = Array.isArray(conversation?.participants)
            ? conversation.participants
            : [];

        const senderIdString = senderId.toString();
        const recipientIds = new Set<string>(
            participants
                .map((participant: any) => {
                    const userId = participant?.userId;
                    if (!userId) return "";
                    return typeof userId?.toString === "function"
                        ? userId.toString()
                        : String(userId);
                })
                .filter((id: string) => id && id !== senderIdString),
        );

        if (recipientIds.size === 0) {
            return;
        }

        const isGroup = conversation?.type === "group";
        const title = isGroup ? "Tin nhan nhom moi" : "Tin nhan moi";
        const body = isGroup
            ? "vua gui tin nhan trong nhom."
            : "vua gui tin nhan cho ban.";

        await Promise.all(
            Array.from(recipientIds).map((recipientId: string) =>
                this.notificationService.createNotification({
                    recipientId: new Types.ObjectId(recipientId),
                    actorId: senderId,
                    type: "MESSAGE_NEW",
                    title,
                    body,
                    entityType: "conversation",
                    entityId: conversation?._id?.toString?.() || "",
                    metadata: {
                        conversationId: conversation?._id?.toString?.() || "",
                        messageId: message?._id?.toString?.() || "",
                        conversationType: conversation?.type || "direct",
                    },
                }),
            ),
        );
    }
}
