import { ConversationRepository } from '../repositories/conversationRepository';
import { MessageRepository } from '../repositories/messageRepository';
import { Types } from 'mongoose';

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

    messages = messages.reverse();

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
}
