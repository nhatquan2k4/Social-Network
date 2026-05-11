import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
    enrichMessageMedia,
    parseManualMedia,
    sanitizeMedia,
} from "../../../src/routes/messages/shared/messages.util.js";

describe("messages shared util", () => {
    describe("sanitizeMedia", () => {
        it("returns undefined when no valid media remains", () => {
            assert.equal(sanitizeMedia(), undefined);
            assert.equal(sanitizeMedia([]), undefined);
            assert.equal(
                sanitizeMedia([
                    { bucket: "", objectKey: "messages/1.png", mimeType: "image/png", size: 1 },
                    { bucket: "social-messages", objectKey: "messages/2.png", mimeType: "", size: 1 },
                    { bucket: "social-messages", objectKey: "messages/3.png", mimeType: "image/png", size: 0 },
                ]),
                undefined,
            );
        });

        it("keeps valid media and normalizes field values", () => {
            const media = sanitizeMedia([
                {
                    bucket: " social-messages ",
                    objectKey: " messages/1.png ",
                    mimeType: " image/png ",
                    size: "300" as unknown as number,
                },
            ]);

            assert.deepEqual(media, [
                {
                    bucket: "social-messages",
                    objectKey: "messages/1.png",
                    mimeType: "image/png",
                    size: 300,
                },
            ]);
        });
    });

    describe("parseManualMedia", () => {
        it("parses valid media from a JSON string", () => {
            const media = parseManualMedia(
                JSON.stringify([
                    {
                        bucket: "social-messages",
                        objectKey: "messages/1.png",
                        mimeType: "image/png",
                        size: 300,
                    },
                ]),
            );

            assert.deepEqual(media, [
                {
                    bucket: "social-messages",
                    objectKey: "messages/1.png",
                    mimeType: "image/png",
                    size: 300,
                },
            ]);
        });

        it("returns an empty array for invalid input", () => {
            assert.deepEqual(parseManualMedia("not json"), []);
            assert.deepEqual(parseManualMedia({ bucket: "social-messages" }), []);
            assert.deepEqual(parseManualMedia(null), []);
        });
    });

    it("adds media URLs to message media", () => {
        const message = {
            _id: "message-1",
            text: "hello",
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

    it("converts legacy imgUrl into media when structured media is absent", () => {
        const message = {
            _id: "message-1",
            text: "hello",
            imgUrl: "https://cdn.example/message.png",
        };

        assert.deepEqual(enrichMessageMedia(message), {
            ...message,
            media: [
                {
                    bucket: "",
                    objectKey: "",
                    mimeType: "image/*",
                    size: 0,
                    mediaUrl: "https://cdn.example/message.png",
                },
            ],
        });
    });
});
