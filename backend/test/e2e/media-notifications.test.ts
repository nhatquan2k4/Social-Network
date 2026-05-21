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
import { minioClient } from "../../src/shared/config/minio.js";

// Mock MinIO Client putObject to skip real S3/MinIO network calls in tests
minioClient.putObject = async () => {
    return {} as any;
};

describe("media & notifications e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("media-notifications");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("covers the media upload flow", async () => {
        const user = await registerAndLogin(context, "media_user");

        // Prepare multipart form data using native FormData
        const pngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
        const pngBuffer = Buffer.from(pngBase64, "base64");
        const formData = new FormData();
        formData.append("purpose", "post");
        const blob = new Blob([pngBuffer], { type: "image/png" });
        formData.append("files", blob, "image.png");

        const uploadResponse = await fetch(`${context.baseUrl}/api/media/upload`, {
            method: "POST",
            headers: authHeaders(user.accessToken),
            body: formData,
        });

        const uploadBody = await readJson<{
            message: string;
            data: Array<{
                bucket: string;
                objectKey: string;
                mimeType: string;
                originalName: string;
                mediaUrl: string;
            }>;
        }>(uploadResponse);

        assert.equal(uploadResponse.status, 201);
        assert.equal(uploadBody.message, "Upload media thanh cong");
        assert.ok(uploadBody.data.length > 0);
        assert.equal(uploadBody.data[0].originalName, "image.png");
        assert.equal(uploadBody.data[0].mimeType, "image/webp");
    });

    it("covers FCM token register and notification updates", async () => {
        const userA = await registerAndLogin(context, "notif_user_a");
        const userB = await registerAndLogin(context, "notif_user_b");

        // 1. Register FCM token
        const fcmResponse = await requestJson(context, "/api/notifications/fcm-token", {
            body: {
                token: "fake_fcm_token_12345",
                platform: "web",
            },
            headers: authHeaders(userA.accessToken),
        });
        const fcmBody = await readJson<{ message: string }>(fcmResponse);
        assert.equal(fcmResponse.status, 200);
        assert.equal(fcmBody.message, "Luu FCM token thanh cong");

        // 2. Remove FCM token
        const removeFcmResponse = await requestJson(context, "/api/notifications/remove-fcm-token", {
            body: {
                token: "fake_fcm_token_12345",
            },
            headers: authHeaders(userA.accessToken),
        });
        assert.equal(removeFcmResponse.status, 200);

        // 3. Let's create a post for userA and have userB like it to trigger a notification!
        const createPostResponse = await requestJson(context, "/api/posts", {
            body: { content: "User A E2E Post" },
            headers: authHeaders(userA.accessToken),
        });
        const postData = await readJson<{ data: { _id?: string; _doc?: { _id: string } } }>(createPostResponse);
        const postId = postData.data._id || postData.data._doc?._id;

        // User B likes User A's post to generate a notification
        const likeResponse = await requestJson(context, `/api/posts/${postId}/like`, {
            headers: authHeaders(userB.accessToken),
        });
        assert.equal(likeResponse.status, 200);

        // 4. Retrieve User A's notifications list
        const notifListResponse = await requestJson(context, "/api/notifications?page=1&limit=10", {
            method: "GET",
            headers: authHeaders(userA.accessToken),
        });
        const notifListBody = await readJson<{
            data: {
                items: Array<{
                    _id: string;
                    id?: string;
                    type: string;
                    isRead: boolean;
                }>;
            };
        }>(notifListResponse);

        assert.equal(notifListResponse.status, 200);
        assert.ok(notifListBody.data.items.length > 0);
        const notif = notifListBody.data.items[0];
        assert.equal(notif.isRead, false);

        const notifId = notif._id || notif.id;

        // 5. Mark notification as read
        const readResponse = await requestJson(context, `/api/notifications/${notifId}/read`, {
            method: "PATCH",
            headers: authHeaders(userA.accessToken),
        });
        const readBody = await readJson<{ message: string }>(readResponse);
        assert.equal(readResponse.status, 200);
        assert.equal(readBody.message, "Da danh dau da doc");

        // 6. Mark all notifications as read
        const readAllResponse = await requestJson(context, "/api/notifications/read-all", {
            method: "PATCH",
            headers: authHeaders(userA.accessToken),
        });
        assert.equal(readAllResponse.status, 200);
    });
});
