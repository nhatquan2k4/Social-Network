export const updateConversationAfterCreateMessage = async (
	conversationId: any,
	message: any,
	senderId: any,
) => {
	const fallbackContent =
		message.content ||
		(Array.isArray(message.media) && message.media.length > 0 ? "[Image]" : null);

	conversationId.set({
		seenBy: [],
		lastMessageAt: message.createdAt,
		lastMessage: {
			_id: message._id,
			content: fallbackContent,
			senderId,
			createdAt: message.createdAt,
		},
	});

	conversationId.participants.forEach((p: any) => {
		const memberId = p.userId.toString();
		const isSender = memberId === senderId.toString();
		const prevCount = conversationId.unreadCounts.get(memberId) || 0;
		conversationId.unreadCounts.set(memberId, isSender ? 0 : prevCount + 1);
	});

	await conversationId.save();
};
