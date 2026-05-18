import { SOCKET_EVENTS, SOCKET_ROOMS } from "./socket.events.js";
import { getSocketIO } from "./socket.server.js";

const withSocket = (action: (io: ReturnType<typeof getSocketIO>) => void) => {
    try {
        const io = getSocketIO();
        action(io);
    } catch (error) {
        // Socket server may be unavailable during startup/tests.
        console.warn("Socket emit skipped:", (error as Error).message);
    }
};

export const emitMessageNew = (conversationId: string, message: unknown) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.conversation(conversationId)).emit(
            SOCKET_EVENTS.MESSAGE_NEW,
            {
                conversationId,
                message,
            },
        );
    });
};

export const emitMessageDeleted = (payload: {
    conversationId: string;
    messageId: string;
    deletedByUserId: string;
    deletedAt: string;
}) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.conversation(payload.conversationId)).emit(
            SOCKET_EVENTS.MESSAGE_DELETED,
            payload,
        );
    });
};

export const emitMessageReaction = (payload: {
    conversationId: string;
    messageId: string;
    reactions: unknown[];
    updatedByUserId: string;
    updatedAt: string;
}) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.conversation(payload.conversationId)).emit(
            SOCKET_EVENTS.MESSAGE_REACTION,
            payload,
        );
    });
};

export const emitConversationSeen = (payload: {
    conversationId: string;
    userId: string;
    seenBy: unknown[];
    myUnreadCount: number;
}) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.conversation(payload.conversationId)).emit(
            SOCKET_EVENTS.CONVERSATION_SEEN,
            payload,
        );
    });
};

export const emitNotificationNew = (recipientId: string, notification: unknown) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.user(recipientId)).emit(SOCKET_EVENTS.NOTIFICATION_NEW, {
            notification,
        });
    });
};

export const emitPostEngagement = (payload: {
    postId: string;
    actorId: string;
    eventId: string;
    type: "like" | "comment";
    likeDelta: number;
    commentDelta: number;
    commentId?: string;
    createdAt: string;
}) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.user(payload.actorId)).emit(
            SOCKET_EVENTS.POST_ENGAGEMENT,
            payload,
        );
    });
};

export const emitMessageSeen = (payload: {
    conversationId: string;
    seenByUserId: string;
    seenByUser: {
        displayName: string;
        avatarUrl: string;
    };
    seenAt: string;
}) => {
    withSocket((io) => {
        io.to(SOCKET_ROOMS.conversation(payload.conversationId)).emit(
            SOCKET_EVENTS.MESSAGE_SEEN,
            payload,
        );
    });
};

export const emitUserPresence = (
    userId: string,
    isOnline: boolean,
    targetFriendIds: string[],
) => {
    withSocket((io) => {
        const event = isOnline
            ? SOCKET_EVENTS.USER_ONLINE
            : SOCKET_EVENTS.USER_OFFLINE;
        const payload = {
            userId,
            isOnline,
            timestamp: new Date().toISOString(),
        };

        for (const friendId of targetFriendIds) {
            io.to(SOCKET_ROOMS.user(friendId)).emit(event, payload);
        }
    });
};
