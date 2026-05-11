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

describe("protected routes e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    before(async () => {
        context = await startE2EApp("protected_routes");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("rejects a protected route without an access token", async () => {
        const response = await requestJson(context, "/api/posts/feed", {
            method: "GET",
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 401);
        assert.deepEqual(body, {
            message: "Khong tim thay access token. Vui long dang nhap",
        });
    });

    it("rejects a protected route with an invalid access token", async () => {
        const response = await requestJson(context, "/api/posts/feed", {
            method: "GET",
            headers: authHeaders("not-a-real-token"),
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 403);
        assert.deepEqual(body, {
            message: "Access token het han hoac khong hop le",
        });
    });

    it("allows a valid access token to call a protected endpoint", async () => {
        const user = await registerAndLogin(context, "protected_ok");

        const response = await requestJson(context, "/api/posts/feed", {
            method: "GET",
            headers: authHeaders(user.accessToken),
        });
        const body = await readJson<{ data: { items: unknown[] } }>(response);

        assert.equal(response.status, 200);
        assert.ok(Array.isArray(body.data.items));
    });

    it("blocks a regular user from admin routes", async () => {
        const user = await registerAndLogin(context, "protected_admin");

        const response = await requestJson(context, "/api/admin/reports", {
            method: "GET",
            headers: authHeaders(user.accessToken),
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 403);
        assert.deepEqual(body, {
            message: "Khong co quyen truy cap. Yeu cau quyen admin",
        });
    });
});
