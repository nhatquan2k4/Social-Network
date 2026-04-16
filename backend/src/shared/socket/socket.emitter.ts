import { SOCKET_EVENTS, SOCKET_ROOMS } from "./socket.events";
import { getSocketIO } from "./socket.server";

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
