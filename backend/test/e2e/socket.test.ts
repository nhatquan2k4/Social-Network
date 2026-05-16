import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
import { io as createSocketClient, type Socket } from "socket.io-client";
import { PresenceService } from "../../src/shared/socket/presence.service.js";
import {
    authHeaders,
    createFriendship,
    E2EContext,
    readJson,
    registerAndLogin,
    requestJson,
    skipDbE2E,
    startE2EApp,
} from "../helpers/e2e.js";

const waitForEvent = <T>(
    socket: Socket,
    eventName: string,
    timeoutMs = 8_000,
): Promise<T> => {
    return new Promise((resolve, reject) => {
        const timer = setTimeout(() => {
            cleanup();
            reject(new Error(`Timed out waiting for socket event "${eventName}"`));
        }, timeoutMs);

        const onEvent = (payload: T) => {
            cleanup();
            resolve(payload);
        };

        const onConnectError = (error: Error) => {
            cleanup();
            reject(error);
        };

        const cleanup = () => {
            clearTimeout(timer);
            socket.off(eventName, onEvent);
            socket.off("connect_error", onConnectError);
        };

        socket.once(eventName, onEvent);
        socket.once("connect_error", onConnectError);
    });
};

const connectSocket = async (baseUrl: string, token: string) => {
    const socket = createSocketClient(baseUrl, {
        auth: { token },
        transports: ["websocket"],
        forceNew: true,
        reconnection: false,
    });

    const connected = await waitForEvent<{
        userId: string;
        joinedConversationCount: number;
    }>(socket, "connected");

    return { socket, connected };
};

describe("socket.io e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;
    const sockets: Socket[] = [];

    const disconnectTrackedSockets = async () => {
        if (sockets.length === 0) {
            PresenceService.getInstance().clearPendingOfflineTimers();
            return;
        }

        sockets.splice(0).forEach((socket) => socket.disconnect());
        await new Promise((resolve) => setTimeout(resolve, 25));
        PresenceService.getInstance().clearPendingOfflineTimers();
    };

    before(async () => {
        context = await startE2EApp("socket", { socket: true });
    });

    beforeEach(async () => {
        await disconnectTrackedSockets();
        await context.cleanupDatabase();
    });

    after(async () => {
        await disconnectTrackedSockets();
        await context.close();
    });

    it("rejects socket connections without an access token", async () => {
        const socket = createSocketClient(context.baseUrl, {
            transports: ["websocket"],
            forceNew: true,
            reconnection: false,
        });

        try {
            const error = await waitForEvent<Error>(socket, "connect_error", 5_000);
            assert.equal(error.message, "Khong tim thay access token");
        } finally {
            socket.disconnect();
        }
    });

    it("connects with a valid token, joins rooms, emits messages and presence events", async () => {
        const userA = await registerAndLogin(context, "socket_a");
        const userB = await registerAndLogin(context, "socket_b");
        await createFriendship(context, userA, userB);

        const conversationResponse = await requestJson(context, "/api/conversations", {
            body: {
                type: "direct",
                recipientId: userB.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const conversationBody = await readJson<{ conversation: { _id: string } }>(
            conversationResponse,
        );
        assert.equal(conversationResponse.status, 201);

        const conversationId = conversationBody.conversation._id;

        const userBConnection = await connectSocket(context.baseUrl, userB.accessToken);
        sockets.push(userBConnection.socket);
        assert.equal(userBConnection.connected.userId, userB.userId);
        assert.equal(userBConnection.connected.joinedConversationCount, 1);

        const userOnline = waitForEvent<{
            userId: string;
            isOnline: boolean;
        }>(userBConnection.socket, "user:online");

        const userAConnection = await connectSocket(context.baseUrl, userA.accessToken);
        sockets.push(userAConnection.socket);
        assert.equal(userAConnection.connected.userId, userA.userId);
        assert.equal(userAConnection.connected.joinedConversationCount, 1);

        const onlinePayload = await userOnline;
        assert.equal(onlinePayload.userId, userA.userId);
        assert.equal(onlinePayload.isOnline, true);
        assert.equal(typeof (onlinePayload as any).timestamp, "string");
    });

    it("delivers message:new over the conversation room", async () => {
        const userA = await registerAndLogin(context, "socket_msg_a");
        const userB = await registerAndLogin(context, "socket_msg_b");
        await createFriendship(context, userA, userB);

        const conversationResponse = await requestJson(context, "/api/conversations", {
            body: {
                type: "direct",
                recipientId: userB.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const conversationBody = await readJson<{ conversation: { _id: string } }>(
            conversationResponse,
        );
        assert.equal(conversationResponse.status, 201);

        const conversationId = conversationBody.conversation._id;
        const userBConnection = await connectSocket(context.baseUrl, userB.accessToken);
        sockets.push(userBConnection.socket);
        const userAConnection = await connectSocket(context.baseUrl, userA.accessToken);
        sockets.push(userAConnection.socket);

        const messageEvent = waitForEvent<{
            conversationId: string;
            message: { _id: string; content: string };
        }>(userBConnection.socket, "message:new");

        const sendResponse = await requestJson(context, "/api/messages/direct/text", {
            body: {
                recipientId: userB.userId,
                conversationId,
                content: "Socket delivered message",
            },
            headers: authHeaders(userA.accessToken),
        });
        const sendBody = await readJson<{ data: { _id: string } }>(sendResponse);
        assert.equal(sendResponse.status, 201);

        const delivered = await messageEvent;
        assert.equal(delivered.conversationId, conversationId);
        assert.equal(delivered.message._id, sendBody.data._id);
        assert.equal(delivered.message.content, "Socket delivered message");

        userAConnection.socket.disconnect();
    });
});
