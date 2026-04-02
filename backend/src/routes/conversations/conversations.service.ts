import { ConversationRepository } from './conversations.repo';
import { MessageRepository } from '../messages/messages.repo';
import { Types } from 'mongoose';
import { buildMediaUrl } from '../../shared/config/minio';

interface PopulatedUser {
    _id: Types.ObjectId;
    displayName: string;
    avatarUrl?: string;
}

export class ConversationService {
  private conversationRepository: ConversationRepository;
  private messageRepository: MessageRepository;

  constructor() {
    this.conversationRepository = new ConversationRepository();
    this.messageRepository = new MessageRepository();
  }

  private enrichMessageMedia(message: any) {
    const plain = typeof message.toObject === "function" ? message.toObject() : message;

    const media = (plain.media || []).map((item: any) => ({
      ...item,
      mediaUrl: buildMediaUrl(item.bucket, item.objectKey),
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
            bucket: "",
            objectKey: "",
            mimeType: "image/*",
            size: 0,
            mediaUrl: plain.imgUrl,
          },
        ],
      };
    }

    return plain;
  }

  async createConversation(
    userId: Types.ObjectId,
    type: string,
    memberIds: string[],
    name?: string,
  ) {
    let conversation;

    if (type === "direct") {
      const participantId = memberIds[0];

      // Tim conversation da ton tai
      conversation = await this.conversationRepository.findDirectConversation(
        userId,
        participantId as any,
      );

      if (!conversation) {
        conversation = await this.conversationRepository.create({
          type: "direct",
          participants: [{ userId }, { userId: participantId }],
          lastMessageAt: new Date(),
        });
      }
    } else if (type === "group") {
      conversation = await this.conversationRepository.create({
        type: "group",
        participants: [{ userId }, ...memberIds.map((id) => ({ userId: id }))],
        group: {
          name,
          createdBy: userId,
        },
        lastMessageAt: new Date(),
      });
    } else {
      throw new Error("Conversation type khong hop le");
    }

    // Populate
    await conversation.populate([
      { path: "participants.userId", select: "displayName avatarUrl" },
      { path: "seenBy", select: "displayName avatarUrl" },
      { path: "lastMessage.senderId", select: "displayName avatarUrl" },
    ]);

    // Format participants
    const participants = (conversation.participants || []).map((p: any) => {
      const user = p.userId as any as PopulatedUser;
      return {
        _id: user?._id,
        displayName: user?.displayName,
        avatarUrl: user?.avatarUrl ?? null,
        joinedAt: p.joinedAt,
      };
    });

    return { ...conversation.toObject(), participants };
  }

  async getConversations(userId: Types.ObjectId, recipientId?: string) {
    let conversations;

    if (recipientId) {
      // Tìm conversation với recipient cụ thể
      const conversation =
        await this.conversationRepository.findDirectConversation(
          userId,
          recipientId as any,
        );
      conversations = conversation ? [conversation] : [];
    } else {
      // Lấy tất cả conversations
      conversations = await this.conversationRepository.findByUserId(userId);
    }

    const formatted = conversations.map((convo: any) => {
      const participants = (convo.participants || []).map((p: any) => {
        const user = p.userId as any as PopulatedUser;
        return {
          _id: user?._id,
          displayName: user?.displayName,
          avatarUrl: user?.avatarUrl ?? null,
          joinedAt: p.joinedAt,
        };
      });

      return {
        ...convo.toObject(),
        unreadCounts: convo.unreadCounts || {},
        participants,
      };
    });

    return formatted;
  }

  async getMessages(
    conversationId: string,
    limit: number = 50,
    cursor?: string,
  ) {
    const query: any = { conversationId };

    if (cursor) {
      query.createdAt = { $lt: new Date(cursor) };
    }

    let messages = await this.messageRepository.findByConversationId(
      conversationId,
      query,
      Number(limit) + 1,
    );

    let nextCursor = null;

    if (messages.length > Number(limit)) {
      const nextMessage = messages[messages.length - 1];
      nextCursor = (nextMessage as any).createdAt.toISOString();
      messages.pop();
    }

    messages = messages.reverse().map((message: any) => this.enrichMessageMedia(message));

    return { messages, nextCursor };
  }

  async getUserConversationsForSocketIO(userId: string | Types.ObjectId) {
    try {
      const conversations =
        await this.conversationRepository.findUserConversationIds(userId);
      return conversations.map((c: any) => c._id.toString());
    } catch (error) {
      console.error("Loi khi fetch conversations: ", error);
      return [];
    }
  }

  async markAsSeen(conversationId: string, userId: string) {
    const conversation =
      await this.conversationRepository.findByIdLean(conversationId);

    if (!conversation) {
      throw new Error("Conversation khong ton tai");
    }

    const last = conversation.lastMessage;

    if (!last) {
      return { message: "Khong co tin nhan de mark as seen" };
    }

    if (!last.senderId || last.senderId.toString() === userId) {
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
      throw new Error("Conversation khong ton tai");
    }

    if (conversation.type !== "group") {
      throw new Error("Chi ho tro roi nhom cho group conversation");
    }

    const me = userId.toString();
    const isMember = (conversation.participants || []).some(
      (participant: any) => participant.userId.toString() === me,
    );

    if (!isMember) {
      throw new Error("Ban khong o trong group nay");
    }

    conversation.participants = (conversation.participants || []).filter(
      (participant: any) => participant.userId.toString() !== me,
    ) as any;

    conversation.seenBy = (conversation.seenBy || []).filter(
      (reader: any) => reader.toString() !== me,
    ) as any;

    if (conversation.unreadCounts && typeof conversation.unreadCounts.delete === "function") {
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
      const sorted = [...remainedParticipants].sort((a: any, b: any) => {
        const aTime = a.joinedAt ? new Date(a.joinedAt).getTime() : 0;
        const bTime = b.joinedAt ? new Date(b.joinedAt).getTime() : 0;
        return aTime - bTime;
      });

      const newOwner = sorted[0];
      if (!newOwner) {
        throw new Error("Khong tim thay owner moi");
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
