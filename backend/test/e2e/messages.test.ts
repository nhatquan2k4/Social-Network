import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
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

describe("conversations and messages e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("messages");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("covers direct conversation, send/list/read/seen/reaction/delete message flow", async () => {
        const userA = await registerAndLogin(context, "message_a");
        const userB = await registerAndLogin(context, "message_b");
        await createFriendship(context, userA, userB);

        const conversationResponse = await requestJson(context, "/api/conversations", {
            body: {
                type: "direct",
                recipientId: userB.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const conversationBody = await readJson<{
            conversation: {
                _id: string;
                type: string;
                recipientId: string;
                participants: unknown[];
            };
        }>(conversationResponse);

        assert.equal(conversationResponse.status, 201);
        assert.equal(conversationBody.conversation.type, "direct");
        assert.equal(conversationBody.conversation.recipientId, userB.userId);
        assert.ok(conversationBody.conversation._id);

        const conversationId = conversationBody.conversation._id;

        const conversationsResponse = await requestJson(context, "/api/conversations", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const conversationsBody = await readJson<{
            conversations: Array<{ _id: string }>;
        }>(conversationsResponse);

        assert.equal(conversationsResponse.status, 200);
        assert.ok(
            conversationsBody.conversations.some(
                (conversation) => conversation._id === conversationId,
            ),
        );

        const sendResponse = await requestJson(context, "/api/messages/direct/text", {
            body: {
                recipientId: userB.userId,
                conversationId,
                content: "Hello from messages E2E",
            },
            headers: authHeaders(userA.accessToken),
        });
        const sendBody = await readJson<{
            message: string;
            data: {
                _id: string;
                content: string;
            };
        }>(sendResponse);

        assert.equal(sendResponse.status, 201);
        assert.equal(sendBody.message, "Da gui tin nhan truc tiep");
        assert.equal(sendBody.data.content, "Hello from messages E2E");
        assert.ok(sendBody.data._id);

        const messageId = sendBody.data._id;

        const listResponse = await requestJson(
            context,
            `/api/messages/${conversationId}/messages`,
            {
                method: "GET",
                headers: authHeaders(userB.accessToken),
            },
        );
        const listBody = await readJson<{
            data: Array<{ _id: string; content: string }>;
            pageInfo: { hasMore: boolean; limit: number; nextCursor: string | null };
        }>(listResponse);

        assert.equal(listResponse.status, 200);
        assert.equal(listBody.data.length, 1);
        assert.equal(listBody.data[0]._id, messageId);
        assert.equal(listBody.data[0].content, "Hello from messages E2E");
        assert.equal(listBody.pageInfo.hasMore, false);

        const markReadResponse = await requestJson(
            context,
            `/api/messages/${conversationId}/messages/${messageId}/read`,
            {
                method: "PATCH",
                headers: authHeaders(userB.accessToken),
            },
        );
        const markReadBody = await readJson<{
            message: string;
            data: { readBy: Array<{ userId: { _id?: string } | string }> };
        }>(markReadResponse);

        assert.equal(markReadResponse.status, 200);
        assert.equal(markReadBody.message, "Da danh dau tin nhan da doc");
        assert.ok(markReadBody.data.readBy.length >= 1);

        const bulkSeenResponse = await requestJson(
            context,
            `/api/messages/${conversationId}/messages/seen`,
            {
                method: "PATCH",
                body: {
                    lastMessageId: messageId,
                },
                headers: authHeaders(userB.accessToken),
            },
        );
        const bulkSeenBody = await readJson<{
            message: string;
            data: { matchedCount: number; readUntil: string | null };
        }>(bulkSeenResponse);

        assert.equal(bulkSeenResponse.status, 200);
        assert.equal(bulkSeenBody.message, "Da danh dau nhieu tin nhan da doc");
        assert.ok(bulkSeenBody.data.matchedCount >= 1);
        assert.ok(bulkSeenBody.data.readUntil);

        const conversationSeenResponse = await requestJson(
            context,
            `/api/conversations/${conversationId}/seen`,
            {
                method: "PATCH",
                headers: authHeaders(userB.accessToken),
            },
        );
        const conversationSeenBody = await readJson<{ message: string }>(
            conversationSeenResponse,
        );

        assert.equal(conversationSeenResponse.status, 200);
        assert.equal(conversationSeenBody.message, "Marked as seen");

        const reactResponse = await requestJson(context, `/api/messages/${messageId}/reaction`, {
            method: "PUT",
            body: {
                emoji: "like",
            },
            headers: authHeaders(userB.accessToken),
        });
        const reactBody = await readJson<{
            message: string;
            data: { reactions: Array<{ emoji: string }> };
        }>(reactResponse);

        assert.equal(reactResponse.status, 200);
        assert.equal(reactBody.message, "Cap nhat reaction thanh cong");
        assert.ok(reactBody.data.reactions.some((reaction) => reaction.emoji === "like"));

        const removeReactionResponse = await requestJson(
            context,
            `/api/messages/${messageId}/reaction`,
            {
                method: "DELETE",
                headers: authHeaders(userB.accessToken),
            },
        );
        const removeReactionBody = await readJson<{
            message: string;
            data: { reactions: unknown[] };
        }>(removeReactionResponse);

        assert.equal(removeReactionResponse.status, 200);
        assert.equal(removeReactionBody.message, "Da go reaction tin nhan");
        assert.equal(removeReactionBody.data.reactions.length, 0);

        const deleteResponse = await requestJson(
            context,
            `/api/messages/${conversationId}/messages/${messageId}`,
            {
                method: "DELETE",
                headers: authHeaders(userA.accessToken),
            },
        );
        const deleteBody = await readJson<{
            message: string;
            data: { conversationId: string; messageId: string; deletedByUserId: string };
        }>(deleteResponse);

        assert.equal(deleteResponse.status, 200);
        assert.equal(deleteBody.message, "Da go tin nhan");
        assert.equal(deleteBody.data.conversationId, conversationId);
        assert.equal(deleteBody.data.messageId, messageId);
        assert.equal(deleteBody.data.deletedByUserId, userA.userId);

        const listAfterDeleteResponse = await requestJson(
            context,
            `/api/messages/${conversationId}/messages`,
            {
                method: "GET",
                headers: authHeaders(userB.accessToken),
            },
        );
        const listAfterDeleteBody = await readJson<{ data: unknown[] }>(
            listAfterDeleteResponse,
        );

        assert.equal(listAfterDeleteResponse.status, 200);
        assert.equal(listAfterDeleteBody.data.length, 0);
    });
});
