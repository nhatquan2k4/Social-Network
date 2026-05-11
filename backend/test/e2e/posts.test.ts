import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
import {
    authHeaders,
    E2EContext,
    readJson,
    registerAndLogin,
    requestJson,
    skipDbE2E,
    startE2EApp,
} from "../helpers/e2e.js";

interface PostResponse {
    message?: string;
    data: {
        _id: string;
        _doc?: {
            _id: string;
            content?: string;
        };
        content?: string;
        likesCount?: number;
        commentsCount?: number;
    };
}

const getPostId = (post: PostResponse["data"]) => post._id ?? post._doc?._id;
const getPostContent = (post: PostResponse["data"]) => post.content ?? post._doc?.content;

describe("posts e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("posts");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("covers the text post lifecycle and ownership rules", async () => {
        const author = await registerAndLogin(context, "post_author");
        const otherUser = await registerAndLogin(context, "post_other");

        const createResponse = await requestJson(context, "/api/posts", {
            body: {
                content: "Hello from an E2E post",
            },
            headers: authHeaders(author.accessToken),
        });
        const createBody = await readJson<PostResponse>(createResponse);

        assert.equal(createResponse.status, 201);
        assert.equal(createBody.message, "Tao post thanh cong");
        assert.equal(getPostContent(createBody.data), "Hello from an E2E post");
        assert.ok(getPostId(createBody.data));

        const postId = getPostId(createBody.data);

        const getResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "GET",
            headers: authHeaders(author.accessToken),
        });
        const getBody = await readJson<PostResponse>(getResponse);

        assert.equal(getResponse.status, 200);
        assert.equal(getPostId(getBody.data), postId);
        assert.equal(getPostContent(getBody.data), "Hello from an E2E post");

        const updateResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "PATCH",
            body: {
                content: "Updated E2E post",
            },
            headers: authHeaders(author.accessToken),
        });
        const updateBody = await readJson<PostResponse>(updateResponse);

        assert.equal(updateResponse.status, 200);
        assert.equal(updateBody.message, "Chinh sua post thanh cong");
        assert.equal(getPostContent(updateBody.data), "Updated E2E post");

        const forbiddenUpdateResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "PATCH",
            body: {
                content: "Other user edit attempt",
            },
            headers: authHeaders(otherUser.accessToken),
        });
        const forbiddenUpdateBody = await readJson<{ message: string }>(
            forbiddenUpdateResponse,
        );

        assert.equal(forbiddenUpdateResponse.status, 403);
        assert.deepEqual(forbiddenUpdateBody, {
            message: "Khong co quyen chinh sua post nay",
        });

        const likeResponse = await requestJson(context, `/api/posts/${postId}/like`, {
            headers: authHeaders(otherUser.accessToken),
        });
        const likeBody = await readJson<PostResponse>(likeResponse);

        assert.equal(likeResponse.status, 200);
        assert.equal(likeBody.message, "Cap nhat like thanh cong");
        assert.equal(likeBody.data.likesCount, 1);

        const unlikeResponse = await requestJson(context, `/api/posts/${postId}/like`, {
            headers: authHeaders(otherUser.accessToken),
        });
        const unlikeBody = await readJson<PostResponse>(unlikeResponse);

        assert.equal(unlikeResponse.status, 200);
        assert.equal(unlikeBody.data.likesCount, 0);

        const commentResponse = await requestJson(context, `/api/posts/${postId}/comments`, {
            body: {
                content: "Nice post",
            },
            headers: authHeaders(otherUser.accessToken),
        });
        const commentBody = await readJson<{
            message: string;
            data: { _id: string; content: string };
        }>(commentResponse);

        assert.equal(commentResponse.status, 201);
        assert.equal(commentBody.message, "Tao comment thanh cong");
        assert.equal(commentBody.data.content, "Nice post");
        assert.ok(commentBody.data._id);

        const commentsResponse = await requestJson(context, `/api/posts/${postId}/comments`, {
            method: "GET",
            headers: authHeaders(author.accessToken),
        });
        const commentsBody = await readJson<{
            data: {
                comments: unknown[];
                flatComments: Array<{ _id: string; content: string }>;
                commentsCount: number;
            };
        }>(commentsResponse);

        assert.equal(commentsResponse.status, 200);
        assert.equal(commentsBody.data.commentsCount, 1);
        assert.equal(commentsBody.data.flatComments[0].content, "Nice post");

        const forbiddenDeleteResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "DELETE",
            headers: authHeaders(otherUser.accessToken),
        });
        const forbiddenDeleteBody = await readJson<{ message: string }>(
            forbiddenDeleteResponse,
        );

        assert.equal(forbiddenDeleteResponse.status, 403);
        assert.deepEqual(forbiddenDeleteBody, {
            message: "Khong co quyen xoa post nay",
        });

        const deleteResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "DELETE",
            headers: authHeaders(author.accessToken),
        });
        const deleteBody = await readJson<{ message: string }>(deleteResponse);

        assert.equal(deleteResponse.status, 200);
        assert.deepEqual(deleteBody, { message: "Xoa post thanh cong" });

        const getDeletedResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "GET",
            headers: authHeaders(author.accessToken),
        });

        assert.equal(getDeletedResponse.status, 404);
    });
});
