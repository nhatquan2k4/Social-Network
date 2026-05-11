import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { updateConversationAfterCreateMessage } from "../../../src/shared/utils/message.helper.js";

const createConversation = () => {
    const state = {
        setPayload: undefined as unknown,
        saved: false,
        seenBy: ["user-2"],
        lastMessageAt: undefined as Date | undefined,
        lastMessage: undefined as unknown,
        participants: [
            { userId: { toString: () => "user-1" } },
            { userId: { toString: () => "user-2" } },
        ],
        unreadCounts: new Map<string, number>([
            ["user-1", 4],
            ["user-2", 2],
        ]),
        set(payload: unknown) {
            this.setPayload = payload;
            Object.assign(this, payload);
        },
        async save() {
            this.saved = true;
        },
    };

    return state;
};

describe("message helper", () => {
    it("updates conversation last message and unread counts for text messages", async () => {
        const conversation = createConversation();
        const createdAt = new Date("2026-01-01T00:00:00.000Z");
        const senderId = { toString: () => "user-1" };

        await updateConversationAfterCreateMessage(
            conversation,
            {
                _id: "message-1",
                content: "Hello",
                createdAt,
            },
            senderId,
        );

        assert.equal(conversation.saved, true);
        assert.deepEqual(conversation.setPayload, {
            seenBy: [],
            lastMessageAt: createdAt,
            lastMessage: {
                _id: "message-1",
                content: "Hello",
                senderId,
                createdAt,
            },
        });
        assert.equal(conversation.unreadCounts.get("user-1"), 0);
        assert.equal(conversation.unreadCounts.get("user-2"), 3);
    });

    it("uses image fallback content when message has media and no text", async () => {
        const conversation = createConversation();
        const createdAt = new Date("2026-01-01T00:00:00.000Z");
        const senderId = { toString: () => "user-2" };

        await updateConversationAfterCreateMessage(
            conversation,
            {
                _id: "message-2",
                media: [{ objectKey: "messages/1.png" }],
                createdAt,
            },
            senderId,
        );

        assert.deepEqual(conversation.lastMessage, {
            _id: "message-2",
            content: "[Image]",
            senderId,
            createdAt,
        });
        assert.equal(conversation.unreadCounts.get("user-1"), 5);
        assert.equal(conversation.unreadCounts.get("user-2"), 0);
    });

    it("uses null fallback content when message has no text or media", async () => {
        const conversation = createConversation();
        const createdAt = new Date("2026-01-01T00:00:00.000Z");
        const senderId = { toString: () => "user-1" };

        await updateConversationAfterCreateMessage(
            conversation,
            {
                _id: "message-3",
                createdAt,
            },
            senderId,
        );

        assert.deepEqual(conversation.lastMessage, {
            _id: "message-3",
            content: null,
            senderId,
            createdAt,
        });
    });
});
