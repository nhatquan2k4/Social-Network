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

describe("friends e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("friends");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("covers request, duplicate prevention, accept, list friends, block and unblock", async () => {
        const userA = await registerAndLogin(context, "friend_a");
        const userB = await registerAndLogin(context, "friend_b");
        const userC = await registerAndLogin(context, "friend_c");

        const selfRequestResponse = await requestJson(context, "/api/friends/requests", {
            body: {
                to: userA.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const selfRequestBody = await readJson<{ message: string }>(selfRequestResponse);

        assert.equal(selfRequestResponse.status, 400);
        assert.deepEqual(selfRequestBody, {
            message: "Khong the gui loi moi ket ban voi chinh ban than",
        });

        const requestResponse = await requestJson(context, "/api/friends/requests", {
            body: {
                to: userB.userId,
                message: "Ket ban nhe",
            },
            headers: authHeaders(userA.accessToken),
        });
        const requestBody = await readJson<{
            message: string;
            request: { _id: string; from: string; to: string };
        }>(requestResponse);

        assert.equal(requestResponse.status, 200);
        assert.equal(requestBody.message, "Da gui loi moi ket ban");
        assert.ok(requestBody.request._id);
        assert.equal(String(requestBody.request.from), userA.userId);
        assert.equal(String(requestBody.request.to), userB.userId);

        const duplicateRequestResponse = await requestJson(context, "/api/friends/requests", {
            body: {
                to: userB.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const duplicateRequestBody = await readJson<{ message: string }>(
            duplicateRequestResponse,
        );

        assert.equal(duplicateRequestResponse.status, 400);
        assert.deepEqual(duplicateRequestBody, {
            message: "Da co loi moi ket ban dang cho duyet",
        });

        const receivedResponse = await requestJson(context, "/api/friends/requests", {
            method: "GET",
            headers: authHeaders(userB.accessToken),
        });
        const receivedBody = await readJson<{
            sent: unknown[];
            received: Array<{ _id: string }>;
        }>(receivedResponse);

        assert.equal(receivedResponse.status, 200);
        assert.equal(receivedBody.received.length, 1);
        assert.equal(receivedBody.received[0]._id, requestBody.request._id);

        const acceptResponse = await requestJson(
            context,
            `/api/friends/requests/${requestBody.request._id}/accept`,
            {
                headers: authHeaders(userB.accessToken),
            },
        );
        const acceptBody = await readJson<{
            message: string;
            newFriend: { _id: string; displayName: string };
        }>(acceptResponse);

        assert.equal(acceptResponse.status, 200);
        assert.equal(acceptBody.message, "Da chap nhan loi moi ket ban");
        assert.equal(acceptBody.newFriend._id, userA.userId);

        const friendsAResponse = await requestJson(context, "/api/friends", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const friendsABody = await readJson<{ friends: Array<{ _id: string }> }>(
            friendsAResponse,
        );

        assert.equal(friendsAResponse.status, 200);
        assert.ok(friendsABody.friends.some((friend) => friend._id === userB.userId));

        const friendsBResponse = await requestJson(context, "/api/friends", {
            method: "GET",
            headers: authHeaders(userB.accessToken),
        });
        const friendsBBody = await readJson<{ friends: Array<{ _id: string }> }>(
            friendsBResponse,
        );

        assert.equal(friendsBResponse.status, 200);
        assert.ok(friendsBBody.friends.some((friend) => friend._id === userA.userId));

        const blockResponse = await requestJson(context, "/api/friends/blocks", {
            body: {
                userId: userC.userId,
            },
            headers: authHeaders(userA.accessToken),
        });
        const blockBody = await readJson<{ message: string; data: { blockedId: string } }>(
            blockResponse,
        );

        assert.equal(blockResponse.status, 201);
        assert.equal(blockBody.message, "Da block nguoi dung");
        assert.equal(String(blockBody.data.blockedId), userC.userId);

        const blocksResponse = await requestJson(context, "/api/friends/blocks", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const blocksBody = await readJson<{ data: Array<{ blockedId: { _id: string } }> }>(
            blocksResponse,
        );

        assert.equal(blocksResponse.status, 200);
        assert.ok(blocksBody.data.some((block) => block.blockedId._id === userC.userId));

        const unblockResponse = await requestJson(
            context,
            `/api/friends/blocks/${userC.userId}`,
            {
                method: "DELETE",
                headers: authHeaders(userA.accessToken),
            },
        );
        const unblockBody = await readJson<{ message: string }>(unblockResponse);

        assert.equal(unblockResponse.status, 200);
        assert.deepEqual(unblockBody, { message: "Da bo block nguoi dung" });

        const blocksAfterUnblockResponse = await requestJson(context, "/api/friends/blocks", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const blocksAfterUnblockBody = await readJson<{ data: unknown[] }>(
            blocksAfterUnblockResponse,
        );

        assert.equal(blocksAfterUnblockResponse.status, 200);
        assert.equal(blocksAfterUnblockBody.data.length, 0);
    });
});
