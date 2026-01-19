import message from "../models/message"

export const updateConversationAfterCreateMessage = async (
  conversationId: any,
  message: any,
  senderId: any
) => {
  conversationId.set({
    seenBy:[],
    lastMessageAt: message.createdAt,
    lastMessage: {
      _id: message._id,
      content: message.content,
      senderId,
      createdAt: message.createdAt,
    },
  });

  conversationId.participants.forEach((p: any) => {
    const memberId = p.userId.toString();
    const isSender = memberId === senderId.toString();
    const prevCount = conversationId.unreadCounts.get(memberId) || 0;
    conversationId.unreadCounts.set(
      memberId,
      isSender ? 0 : prevCount + 1
    );
  });

  await conversationId.save();
}