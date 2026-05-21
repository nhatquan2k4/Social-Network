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
import { UserModel } from "../../src/routes/users/shared/users.model.js";

describe("users & admin e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("users-admin");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("covers the user profile retrieval, update, other profile retrieval, and search flows", async () => {
        const userA = await registerAndLogin(context, "user_a");
        const userB = await registerAndLogin(context, "user_b");

        // 1. Get Me (User A profile)
        const getMeResponse = await requestJson(context, "/api/users/me", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const getMeBody = await readJson<{ user: { username: string; displayName: string } }>(getMeResponse);
        assert.equal(getMeResponse.status, 200);
        assert.ok(getMeBody.user.username);

        // 2. Update Me (User A profile updates)
        const updateMeResponse = await requestJson(context, "/api/users/me", {
            method: "PATCH",
            body: {
                displayName: "User A Updated Name",
                bio: "Software developer E2E",
                phone: "0987654321",
            },
            headers: authHeaders(userA.accessToken),
        });
        const updateMeBody = await readJson<{ message: string; user: { displayName: string; bio: string } }>(updateMeResponse);
        assert.equal(updateMeResponse.status, 200);
        assert.equal(updateMeBody.message, "Cap nhat thong tin thanh cong");
        assert.equal(updateMeBody.user.displayName, "User A Updated Name");
        assert.equal(updateMeBody.user.bio, "Software developer E2E");

        // 3. Get User B's profile from User A
        const otherProfileResponse = await requestJson(context, `/api/users/${userB.userId}/profile`, {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const otherProfileBody = await readJson<{ data: { user: { username: string } } }>(otherProfileResponse);
        assert.equal(otherProfileResponse.status, 200);
        assert.ok(otherProfileBody.data.user.username);

        // 4. Search user by display name
        const searchResponse = await requestJson(context, "/api/users/search?name=User A Updated Name", {
            method: "GET",
            headers: authHeaders(userB.accessToken),
        });
        const searchBody = await readJson<{ data: Array<{ displayName: string }> }>(searchResponse);
        assert.equal(searchResponse.status, 200);
        assert.ok(searchBody.data.length > 0);
        assert.equal(searchBody.data[0].displayName, "User A Updated Name");
    });

    it("covers the admin post moderation flows (hide, restore, delete)", async () => {
        const adminUser = await registerAndLogin(context, "admin_user");
        const regularUser = await registerAndLogin(context, "regular_user");

        // 1. Elevate adminUser to "admin" role in the Mongoose database
        await UserModel.updateOne({ _id: adminUser.userId }, { role: "admin" });

        // 2. Regular user creates a post
        const createPostResponse = await requestJson(context, "/api/posts", {
            body: { content: "Offensive post contents" },
            headers: authHeaders(regularUser.accessToken),
        });
        const postData = await readJson<{ data: { _id?: string; _doc?: { _id: string } } }>(createPostResponse);
        const postId = postData.data._id || postData.data._doc?._id;

        // 3. Admin hides the post
        const hideResponse = await requestJson(context, `/api/admin/posts/${postId}/hide`, {
            method: "PATCH",
            body: { reviewNote: "Violated community standards" },
            headers: authHeaders(adminUser.accessToken),
        });
        const hideBody = await readJson<{ message?: string; action?: string }>(hideResponse);
        assert.equal(hideResponse.status, 200);

        // 4. Admin restores the post
        const restoreResponse = await requestJson(context, `/api/admin/posts/${postId}/restore`, {
            method: "PATCH",
            body: { reviewNote: "False alarm, restoring" },
            headers: authHeaders(adminUser.accessToken),
        });
        assert.equal(restoreResponse.status, 200);

        // 5. Admin deletes the post completely
        const deleteResponse = await requestJson(context, `/api/admin/posts/${postId}`, {
            method: "DELETE",
            body: { reviewNote: "Final deletion" },
            headers: authHeaders(adminUser.accessToken),
        });
        assert.equal(deleteResponse.status, 200);

        // 6. Verify that it was deleted
        const getPostResponse = await requestJson(context, `/api/posts/${postId}`, {
            method: "GET",
            headers: authHeaders(regularUser.accessToken),
        });
        assert.equal(getPostResponse.status, 404);
    });
});
