import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
    buildCommentTree,
    collectDescendantCommentIds,
    formatComment,
    formatPost,
    normalizeUploadedMedia,
    parseManualMedia,
} from "../../../src/routes/posts/shared/posts.util.js";

describe("posts shared util", () => {
    describe("parseManualMedia", () => {
        it("returns valid media from a JSON string and trims string fields", () => {
            const media = parseManualMedia(
                JSON.stringify([
                    {
                        bucket: " social-posts ",
                        objectKey: " posts/1.png ",
                        mimeType: " image/png ",
                        size: "120",
                    },
                ]),
            );

            assert.deepEqual(media, [
                {
                    bucket: "social-posts",
                    objectKey: "posts/1.png",
                    mimeType: "image/png",
                    size: 120,
                },
            ]);
        });

        it("drops malformed media entries", () => {
            const media = parseManualMedia([
                null,
                "not an object",
                { bucket: "social-posts", objectKey: "", mimeType: "image/png", size: 100 },
                { bucket: "social-posts", objectKey: "posts/1.png", mimeType: "image/png", size: 0 },
                { bucket: "social-posts", objectKey: "posts/2.png", mimeType: "image/png", size: 42 },
            ]);

            assert.deepEqual(media, [
                {
                    bucket: "social-posts",
                    objectKey: "posts/2.png",
                    mimeType: "image/png",
                    size: 42,
                },
            ]);
        });

        it("returns an empty array for invalid JSON or non-array input", () => {
            assert.deepEqual(parseManualMedia("{broken json"), []);
            assert.deepEqual(parseManualMedia({ bucket: "social-posts" }), []);
            assert.deepEqual(parseManualMedia(undefined), []);
        });
    });

    it("normalizes uploaded media to the persisted fields", () => {
        const media = normalizeUploadedMedia([
            {
                bucket: "social-posts",
                objectKey: "posts/1.png",
                mimeType: "image/png",
                size: 120,
                ignored: true,
            },
        ]);

        assert.deepEqual(media, [
            {
                bucket: "social-posts",
                objectKey: "posts/1.png",
                mimeType: "image/png",
                size: 120,
            },
        ]);
    });

    it("adds media URLs and like counts when formatting a post", () => {
        const post = {
            _id: "post-1",
            authorId: "user-1",
            content: "hello",
            media: [
                {
                    bucket: "social-posts",
                    objectKey: "posts/1.png",
                    mimeType: "image/png",
                    size: 120,
                },
            ],
            likes: ["user-2", "user-3"],
            createdAt: new Date("2026-01-01T00:00:00.000Z"),
            updatedAt: new Date("2026-01-01T00:00:00.000Z"),
        };

        assert.deepEqual(formatPost(post), {
            ...post,
            media: [
                {
                    bucket: "social-posts",
                    objectKey: "posts/1.png",
                    mimeType: "image/png",
                    size: 120,
                    mediaUrl: "http://localhost:9000/social-posts/posts/1.png",
                },
            ],
            likesCount: 2,
        });
    });

    it("formats comments with a null parent id when it is absent", () => {
        const createdAt = new Date("2026-01-01T00:00:00.000Z");
        const updatedAt = new Date("2026-01-02T00:00:00.000Z");

        assert.deepEqual(
            formatComment({
                _id: "comment-1",
                authorId: "user-1",
                content: "Nice post",
                createdAt,
                updatedAt,
            }),
            {
                _id: "comment-1",
                parentCommentId: null,
                authorId: "user-1",
                content: "Nice post",
                createdAt,
                updatedAt,
            },
        );
    });

    it("builds nested comment trees and treats missing parents as roots", () => {
        const comments = [
            { _id: "root", content: "root" },
            { _id: "child", parentCommentId: "root", content: "child" },
            { _id: "orphan", parentCommentId: "missing", content: "orphan" },
        ];

        assert.deepEqual(buildCommentTree(comments), [
            {
                _id: "root",
                content: "root",
                children: [
                    {
                        _id: "child",
                        parentCommentId: "root",
                        content: "child",
                        children: [],
                    },
                ],
            },
            {
                _id: "orphan",
                parentCommentId: "missing",
                content: "orphan",
                children: [],
            },
        ]);
    });

    it("collects the root comment and all descendant ids", () => {
        const ids = collectDescendantCommentIds(
            [
                { _id: "root" },
                { _id: "child-1", parentCommentId: "root" },
                { _id: "child-2", parentCommentId: "root" },
                { _id: "grandchild", parentCommentId: "child-1" },
                { _id: "unrelated", parentCommentId: "other" },
            ],
            "root",
        );

        assert.deepEqual([...ids].sort(), ["child-1", "child-2", "grandchild", "root"]);
    });
});
