export const SOCKET_EVENTS = {
    CONNECTED: "connected",
    MESSAGE_NEW: "message:new",
    MESSAGE_DELETED: "message:deleted",
    MESSAGE_SEEN: "message:seen",
    CONVERSATION_SEEN: "conversation:seen",
    NOTIFICATION_NEW: "notification:new",
    USER_ONLINE: "user:online",
    USER_OFFLINE: "user:offline",
} as const;

export const SOCKET_ROOMS = {
    user: (userId: string) => `user:${userId}`,
    conversation: (conversationId: string) => `conversation:${conversationId}`,
};
