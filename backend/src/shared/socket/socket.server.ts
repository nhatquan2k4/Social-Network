import jwt from "jsonwebtoken";
import { Server as HttpServer } from "http";
import { Server, Socket } from "socket.io";
import { ConversationService } from "../../routes/conversations/conversation/conversation.service.js";
import { UserModel } from "../../routes/users/shared/users.model.js";
import { SOCKET_EVENTS, SOCKET_ROOMS } from "./socket.events.js";
import { PresenceService } from "./presence.service.js";

type AccessTokenPayload = {
    userId: string;
    username?: string;
    iat?: number;
    exp?: number;
};

let io: Server | null = null;
const conversationService = new ConversationService();

const allowedOrigins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    ...(process.env.CORS_ORIGIN
        ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
        : []),
];

const localDevOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i;

const extractTokenFromSocket = (socket: Socket) => {
    const authToken = socket.handshake.auth?.token;
    if (typeof authToken === "string" && authToken.trim()) {
        return authToken.trim();
    }

    const authorization = socket.handshake.headers.authorization;
    if (typeof authorization === "string" && authorization.startsWith("Bearer ")) {
        return authorization.slice(7).trim();
    }

    return null;
};

const attachSocketAuth = (socketServer: Server) => {
    socketServer.use(async (socket, next) => {
        try {
            const token = extractTokenFromSocket(socket);
            if (!token) {
                return next(new Error("Khong tim thay access token"));
            }

            const decoded = jwt.verify(
                token,
                process.env.ACCESS_TOKEN_SECRET as string,
            ) as AccessTokenPayload;

            const user = await UserModel.findById(decoded.userId)
                .select("_id username displayName avatarUrl")
                .lean();

            if (!user) {
                return next(new Error("Nguoi dung khong ton tai"));
            }

            socket.data.userId = user._id.toString();
            socket.data.user = user;
            return next();
        } catch (error) {
            return next(new Error("Access token het han hoac khong hop le"));
        }
    });
};

const registerSocketEvents = (socketServer: Server) => {
    const presenceService = PresenceService.getInstance();

    socketServer.on("connection", async (socket) => {
        const userId = socket.data.userId as string;

        socket.join(SOCKET_ROOMS.user(userId));

        const conversationIds = await conversationService.getUserConversationsForSocketIO(
            userId,
        );
        conversationIds.forEach((conversationId) => {
            socket.join(SOCKET_ROOMS.conversation(conversationId));
        });

        socket.emit(SOCKET_EVENTS.CONNECTED, {
            userId,
            joinedConversationCount: conversationIds.length,
        });

        // ── Presence tracking ──
        await presenceService.handleConnect(userId);

        socket.on("disconnect", () => {
            presenceService.handleDisconnect(userId).catch((err) => {
                console.error("Presence disconnect error:", err);
            });
        });

        socket.on("conversation:join", async (conversationId: string) => {
            if (!conversationId || typeof conversationId !== "string") {
                return;
            }

            const myConversationIds =
                await conversationService.getUserConversationsForSocketIO(userId);

            if (!myConversationIds.includes(conversationId)) {
                return;
            }

            socket.join(SOCKET_ROOMS.conversation(conversationId));
        });
    });
};

export const initializeSocketIO = (httpServer: HttpServer) => {
    if (io) {
        return io;
    }

    io = new Server(httpServer, {
        cors: {
            origin: (origin, callback) => {
                if (!origin) {
                    return callback(null, true);
                }

                if (
                    allowedOrigins.includes(origin) ||
                    localDevOriginPattern.test(origin)
                ) {
                    return callback(null, true);
                }

                return callback(new Error(`CORS blocked for origin: ${origin}`));
            },
            credentials: true,
        },
    });

    attachSocketAuth(io);
    registerSocketEvents(io);

    return io;
};

export const getSocketIO = () => {
    if (!io) {
        throw new Error("Socket.IO chua duoc khoi tao");
    }

    return io;
};
