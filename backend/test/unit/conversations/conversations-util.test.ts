import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
    enrichMessageMedia,
    mapConversationParticipants,
} from "../../../src/routes/conversations/shared/conversations.util.js";

describe("conversations shared util", () => {
    it("maps populated participants to public participant fields", () => {
        const joinedAt = new Date("2026-01-01T00:00:00.000Z");

        assert.deepEqual(
            mapConversationParticipants([
                {
                    userId: {
                        _id: "user-1",
                        displayName: "Alice",
                        avatarUrl: "https://cdn.example/alice.png",
                    },
                    joinedAt,
                },
                {
                    userId: {
                        _id: "user-2",
                        displayName: "Bob",
                    },
                    joinedAt,
                },
            ]),
            [
                {
                    _id: "user-1",
                    displayName: "Alice",
                    avatarUrl: "https://cdn.example/alice.png",
                    joinedAt,
                },
                {
                    _id: "user-2",
                    displayName: "Bob",
                    avatarUrl: null,
                    joinedAt,
                },
            ],
        );
    });

    it("returns an empty participant list by default", () => {
        assert.deepEqual(mapConversationParticipants(), []);
    });

    it("adds media URLs to message media", () => {
        const message = {
            _id: "message-1",
            media: [
                {
                    bucket: "social-messages",
                    objectKey: "messages/1.png",
                    mimeType: "image/png",
                    size: 300,
                },
            ],
        };

        assert.deepEqual(enrichMessageMedia(message), {
            ...message,
            media: [
                {
                    bucket: "social-messages",
                    objectKey: "messages/1.png",
                    mimeType: "image/png",
                    size: 300,
                    mediaUrl: "http://localhost:9000/social-messages/messages/1.png",
                },
            ],
        });
    });

    it("uses message.toObject when present", () => {
        const message = {
            toObject() {
                return {
                    _id: "message-1",
                    imgUrl: "https://cdn.example/legacy.png",
                };
            },
        };

        assert.deepEqual(enrichMessageMedia(message), {
            _id: "message-1",
            imgUrl: "https://cdn.example/legacy.png",
            media: [
                {
                    bucket: "",
                    objectKey: "",
                    mimeType: "image/*",
                    size: 0,
                    mediaUrl: "https://cdn.example/legacy.png",
                },
            ],
        });
    });
});
