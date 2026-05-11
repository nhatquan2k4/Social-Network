import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import dotenv from "dotenv";
import mongoose from "mongoose";

dotenv.config();

process.env.SMTP_HOST = "";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";

const originalConsoleWarn = console.warn.bind(console);
const originalConsoleInfo = console.info.bind(console);

type CreateApp = (typeof import("../../src/app.js"))["createApp"];
type ConnectDB = (typeof import("../../src/shared/db/mongoose.js"))["connectDB"];
type DisconnectDB = (typeof import("../../src/shared/db/mongoose.js"))["disconnectDB"];

interface TestUser {
    username: string;
    password: string;
    email: string;
    firstName: string;
    lastName: string;
}

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

const testMongoUri = process.env.MONGODB_TEST_CONNECTIONSTRING;
const skipAuthE2E = testMongoUri ? false : "MONGODB_TEST_CONNECTIONSTRING is required";

const getDatabaseName = (connectionString: string): string => {
    const parsed = new URL(connectionString);
    return decodeURIComponent(parsed.pathname.replace(/^\/+/, ""));
};

const assertSafeTestDatabase = (connectionString: string) => {
    const databaseName = getDatabaseName(connectionString);

    if (!databaseName || !databaseName.toLowerCase().includes("test")) {
        throw new Error(
            `Refusing to run Auth E2E cleanup against non-test database "${databaseName}"`,
        );
    }
};

const uniqueId = () => `${Date.now()}_${Math.random().toString(16).slice(2)}`;

const createTestUser = (prefix = "auth_user"): TestUser => {
    const id = uniqueId();

    return {
        username: `${prefix}_${id}`,
        password: "Password123!",
        email: `${prefix}.${id}@example.com`,
        firstName: "Auth",
        lastName: "Tester",
    };
};

const readJson = async <T>(response: Response): Promise<T> => {
    const text = await response.text();
    return (text ? JSON.parse(text) : {}) as T;
};

const cleanupDatabase = async () => {
    const database = mongoose.connection.db;
    if (!database) {
        return;
    }

    const collections = await database.collections();
    await Promise.all(collections.map((collection) => collection.deleteMany({})));
};

describe("auth api e2e", { skip: skipAuthE2E }, () => {
    let createApp: CreateApp;
    let connectDB: ConnectDB;
    let disconnectDB: DisconnectDB;
    let server: Server;
    let baseUrl: string;

    const requestJson = async (
        path: string,
        options: {
            method?: string;
            body?: unknown;
            headers?: Record<string, string>;
        } = {},
    ) => {
        return fetch(`${baseUrl}${path}`, {
            method: options.method ?? "POST",
            headers: {
                "content-type": "application/json",
                ...options.headers,
            },
            body: options.body === undefined ? undefined : JSON.stringify(options.body),
        });
    };

    const registerUser = async (user = createTestUser()) => {
        const response = await requestJson("/api/auth/register", {
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
        const response = await requestJson("/api/auth/login", {
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
        if (!testMongoUri) {
            return;
        }

        console.warn = (...args: unknown[]) => {
            if (String(args[0]).startsWith("SMTP is not configured.")) {
                return;
            }

            originalConsoleWarn(...args);
        };

        console.info = (...args: unknown[]) => {
            if (String(args[0]).startsWith("Verification link for ")) {
                return;
            }

            originalConsoleInfo(...args);
        };

        assertSafeTestDatabase(testMongoUri);

        ({ createApp } = await import("../../src/app.js"));
        ({ connectDB, disconnectDB } = await import("../../src/shared/db/mongoose.js"));

        await connectDB(testMongoUri);
        await cleanupDatabase();

        const app = createApp();
        server = app.listen(0);

        await new Promise<void>((resolve) => {
            server.once("listening", resolve);
        });

        const address = server.address();
        if (!address || typeof address === "string") {
            throw new Error("Test server did not bind to a TCP port");
        }

        baseUrl = `http://127.0.0.1:${(address as AddressInfo).port}`;
    });

    beforeEach(async () => {
        await cleanupDatabase();
    });

    after(async () => {
        if (server) {
            await new Promise<void>((resolve, reject) => {
                server.close((error) => (error ? reject(error) : resolve()));
            });
        }

        await cleanupDatabase();

        if (disconnectDB) {
            await disconnectDB();
        }

        console.warn = originalConsoleWarn;
        console.info = originalConsoleInfo;
    });

    it("registers a user successfully", async () => {
        await registerUser();
    });

    it("rejects duplicate username and duplicate email registrations", async () => {
        const user = await registerUser();

        const duplicateUsernameResponse = await requestJson("/api/auth/register", {
            body: {
                ...createTestUser("duplicate_username"),
                username: user.username,
            },
        });
        const duplicateUsernameBody = await readJson<{ message: string }>(
            duplicateUsernameResponse,
        );

        assert.equal(duplicateUsernameResponse.status, 409);
        assert.deepEqual(duplicateUsernameBody, { message: "Username da ton tai" });

        const duplicateEmailResponse = await requestJson("/api/auth/register", {
            body: {
                ...createTestUser("duplicate_email"),
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

        const response = await requestJson("/api/auth/login", {
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

        const response = await requestJson("/api/auth/refresh-token", {
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

        const reusedOldTokenResponse = await requestJson("/api/auth/refresh-token", {
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

        const response = await requestJson("/api/auth/logout", {
            headers: {
                cookie: `refreshToken=${login.refreshToken}`,
            },
        });

        assert.equal(response.status, 204);
        assert.match(response.headers.get("set-cookie") ?? "", /refreshToken=/);

        const refreshAfterLogoutResponse = await requestJson("/api/auth/refresh-token", {
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

        const response = await requestJson("/api/auth/change-password", {
            body: {
                currentPassword: user.password,
                newPassword,
            },
            headers: {
                authorization: `Bearer ${login.accessToken}`,
            },
        });
        const body = await readJson<{ message: string }>(response);

        assert.equal(response.status, 200);
        assert.deepEqual(body, { message: "Doi mat khau thanh cong" });

        const oldPasswordResponse = await requestJson("/api/auth/login", {
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
