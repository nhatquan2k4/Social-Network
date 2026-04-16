export const SOCKET_EVENTS = {
    CONNECTED: "connected",
    MESSAGE_NEW: "message:new",
    CONVERSATION_SEEN: "conversation:seen",
    NOTIFICATION_NEW: "notification:new",
} as const;

export const SOCKET_ROOMS = {
    user: (userId: string) => `user:${userId}`,
    conversation: (conversationId: string) => `conversation:${conversationId}`,
};
