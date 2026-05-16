import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
import {
    authHeaders,
    createTestUser,
    readJson,
    requestJson,
    skipDbE2E,
    startE2EApp,
} from "../helpers/e2e.js";
import type { E2EContext, TestUserInput } from "../helpers/e2e.js";

type TestUser = TestUserInput;

const createAuthUser = (prefix = "auth_user") => createTestUser(prefix);

interface LoginResponse {
    message: string;
    accessToken: string;
    refreshToken: string;
    isEmailVerified: boolean;
}

interface RefreshTokenResponse {
    message: string;
    accessToken: string;
    refreshToken: string;
}

describe("auth api e2e", { skip: skipDbE2E }, () => {
    let context: E2EContext;

    const registerUser = async (user = createAuthUser()) => {
        const response = await requestJson(context, "/api/auth/register", {
            body: user,
        });
        const body = await readJson<Record<string, unknown>>(response);

        assert.equal(response.status, 201);
        assert.equal(body.requiresEmailVerification, true);
        assert.equal(typeof body.emailVerificationSent, "boolean");
        assert.match(String(body.message), /^Dang ky thanh cong/);

        return user;
    };

    const loginUser = async (user: Pick<TestUser, "username" | "password">) => {
        const response = await requestJson(context, "/api/auth/login", {
            body: {
                username: user.username,
                password: user.password,
            },
        });
        const body = await readJson<LoginResponse>(response);

        assert.equal(response.status, 200);
        assert.equal(body.message, `Nguoi dung ${user.username} dang nhap thanh cong`);
        assert.equal(typeof body.accessToken, "string");
        assert.ok(body.accessToken.length > 0);
        assert.match(body.refreshToken, /^[0-9a-f]{128}$/);
        assert.equal(body.isEmailVerified, false);
        assert.match(response.headers.get("set-cookie") ?? "", /refreshToken=/);

        return body;
    };

    before(async () => {
        context = await startE2EApp("auth");
    });

    beforeEach(async () => {
        await context.cleanupDatabase();
    });

    after(async () => {
        await context.close();
    });

    it("registers a user successfully", async () => {
        await registerUser();
    });

    it("rejects duplicate username and duplicate email registrations", async () => {
        const user = await registerUser();

        const duplicateUsernameResponse = await requestJson(context, "/api/auth/register", {
            body: {
                ...createAuthUser("duplicate_username"),
                username: user.username,
            },
        });
        const duplicateUsernameBody = await readJson<{ message: string }>(
            duplicateUsernameResponse,
        );

        assert.equal(duplicateUsernameResponse.status, 409);
        assert.deepEqual(duplicateUsernameBody, { message: "Username da ton tai" });

        const duplicateEmailResponse = await requestJson(context, "/api/auth/register", {
            body: {
                ...createAuthUser("duplicate_email"),
                email: user.email,
            },
        });
        const duplicateEmailBody = await readJson<{ message: string }>(duplicateEmailResponse);

        assert.equal(duplicateEmailResponse.status, 409);
        assert.deepEqual(duplicateEmailBody, { message: "Email da ton tai" });
    });

    it("logs in with valid credentials", async () => {
        const user = await registerUser();

        await loginUser(user);
    });

    it("rejects login with an invalid password", async () => {
        const user = await registerUser();

        const response = await requestJson(context, "/api/auth/login", {
            body: {
                username: user.username,
                password: "WrongPassword123!",
            },
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 401);
        assert.deepEqual(body, { message: "Sai ten dang nhap hoac mat khau" });
    });

    it("refreshes an access token and rotates the refresh token", async () => {
        const user = await registerUser();
        const login = await loginUser(user);

        const response = await requestJson(context, "/api/auth/refresh-token", {
            body: {
                refreshToken: login.refreshToken,
            },
        });
        const body = await readJson<RefreshTokenResponse>(response);

        assert.equal(response.status, 200);
        assert.equal(body.message, "Cap moi access token thanh cong");
        assert.equal(typeof body.accessToken, "string");
        assert.ok(body.accessToken.length > 0);
        assert.match(body.refreshToken, /^[0-9a-f]{128}$/);
        assert.notEqual(body.refreshToken, login.refreshToken);
        assert.match(response.headers.get("set-cookie") ?? "", /refreshToken=/);

        const reusedOldTokenResponse = await requestJson(context, "/api/auth/refresh-token", {
            body: {
                refreshToken: login.refreshToken,
            },
        });
        const reusedOldTokenBody = await readJson<{ message: string }>(reusedOldTokenResponse);

        assert.equal(reusedOldTokenResponse.status, 401);
        assert.deepEqual(reusedOldTokenBody, {
            message: "Refresh token khong hop le hoac da het han",
        });
    });

    it("logs out by deleting the refresh token session", async () => {
        const user = await registerUser();
        const login = await loginUser(user);

        const response = await requestJson(context, "/api/auth/logout", {
            headers: {
                cookie: `refreshToken=${login.refreshToken}`,
            },
        });

        assert.equal(response.status, 204);
        assert.match(response.headers.get("set-cookie") ?? "", /refreshToken=/);

        const refreshAfterLogoutResponse = await requestJson(context, "/api/auth/refresh-token", {
            body: {
                refreshToken: login.refreshToken,
            },
        });
        const refreshAfterLogoutBody = await readJson<{ message: string }>(
            refreshAfterLogoutResponse,
        );

        assert.equal(refreshAfterLogoutResponse.status, 401);
        assert.deepEqual(refreshAfterLogoutBody, {
            message: "Refresh token khong hop le hoac da het han",
        });
    });

    it("changes password when the current password is correct", async () => {
        const user = await registerUser();
        const login = await loginUser(user);
        const newPassword = "NewPassword123!";

        const response = await requestJson(context, "/api/auth/change-password", {
            body: {
                currentPassword: user.password,
                newPassword,
            },
            headers: authHeaders(login.accessToken),
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 200);
        assert.deepEqual(body, { message: "Doi mat khau thanh cong" });

        const oldPasswordResponse = await requestJson(context, "/api/auth/login", {
            body: {
                username: user.username,
                password: user.password,
            },
        });

        assert.equal(oldPasswordResponse.status, 401);

        await loginUser({
            username: user.username,
            password: newPassword,
        });
    });
});
