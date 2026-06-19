import assert from "node:assert/strict";
import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import dotenv from "dotenv";
import mongoose from "mongoose";
import { MongoMemoryServer } from "mongodb-memory-server";

dotenv.config();

process.env.SMTP_HOST = "";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";

type CreateApp = (typeof import("../../src/app.js"))["createApp"];
type ConnectDB = (typeof import("../../src/shared/db/mongoose.js"))["connectDB"];
type DisconnectDB = (typeof import("../../src/shared/db/mongoose.js"))["disconnectDB"];
type InitializeSocketIO =
    (typeof import("../../src/shared/socket/socket.server.js"))["initializeSocketIO"];

export interface TestUserInput {
    username: string;
    password: string;
    email: string;
    firstName: string;
    lastName: string;
}

export interface AuthenticatedUser {
    user: TestUserInput;
    userId: string;
    accessToken: string;
    refreshToken: string;
}

export interface E2EContext {
    baseUrl: string;
    cleanupDatabase: () => Promise<void>;
    seedData: Awaited<ReturnType<typeof import("../../src/testing/e2e-seed.js").seedE2EDatabase>> | null;
    close: () => Promise<void>;
}

const originalConsoleWarn = console.warn.bind(console);
const originalConsoleInfo = console.info.bind(console);
const originalConsoleError = console.error.bind(console);
let expectedLogsSuppressed = false;

const expectedConsoleErrorPrefixes = [
    "Loi khi gui loi moi ket ban",
    "Loi khi chinh sua post",
    "Loi khi xoa post",
    "Loi khi lay post",
];

// Singleton in-memory server state
let sharedMongoServer: MongoMemoryServer | null = null;
let sharedMongoUri: string | null = null;
let initializationPromise: Promise<string> | null = null;

export const getMongoUri = async (): Promise<string> => {
    if (process.env.USE_REAL_TEST_DB && process.env.MONGODB_TEST_CONNECTIONSTRING) {
        return process.env.MONGODB_TEST_CONNECTIONSTRING;
    }
    if (initializationPromise) {
        return initializationPromise;
    }
    if (sharedMongoUri) {
        return sharedMongoUri;
    }
    initializationPromise = (async () => {
        sharedMongoServer = await MongoMemoryServer.create();
        const uri = sharedMongoServer.getUri();
        sharedMongoUri = uri;
        initializationPromise = null;
        return uri;
    })();
    return initializationPromise;
};

export const stopSharedMongoServer = async () => {
    if (sharedMongoServer) {
        try {
            await sharedMongoServer.stop();
            sharedMongoServer = null;
            sharedMongoUri = null;
        } catch {
            // Ignore error
        }
    }
};

export const testMongoUri = process.env.MONGODB_TEST_CONNECTIONSTRING;
export const skipDbE2E = false; // Always run db-based E2E tests since in-memory DB is always available

const getDatabaseName = (connectionString: string): string => {
    const parsed = new URL(connectionString);
    return decodeURIComponent(parsed.pathname.replace(/^\/+/, ""));
};

const assertSafeTestDatabase = (connectionString: string) => {
    const databaseName = getDatabaseName(connectionString);

    if (!databaseName || !databaseName.toLowerCase().includes("test")) {
        throw new Error(
            `Refusing to run E2E cleanup against non-test database "${databaseName}"`,
        );
    }
};

export const buildSuiteMongoUri = async (suiteName: string): Promise<string> => {
    const baseUri = await getMongoUri();
    
    // Only assert safe test DB if we are using the real configured test DB
    if (process.env.USE_REAL_TEST_DB && process.env.MONGODB_TEST_CONNECTIONSTRING) {
        assertSafeTestDatabase(baseUri);
    }

    const parsed = new URL(baseUri);
    const databaseName = decodeURIComponent(parsed.pathname.replace(/^\/+/, "")) || "test";
    const safeSuiteName = suiteName.replace(/[^a-zA-Z0-9_-]/g, "_").toLowerCase();

    parsed.pathname = `/${databaseName}_${safeSuiteName}`;
    return parsed.toString();
};

const suppressExpectedLogs = () => {
    if (expectedLogsSuppressed) {
        return;
    }

    console.warn = (...args: unknown[]) => {
        if (String(args[0]).startsWith("SMTP is not configured.")) {
            return;
        }

        if (String(args[0]).startsWith("Socket emit skipped:")) {
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

    console.error = (...args: unknown[]) => {
        const message = String(args[0]);
        if (expectedConsoleErrorPrefixes.some((prefix) => message.startsWith(prefix))) {
            return;
        }

        originalConsoleError(...args);
    };

    expectedLogsSuppressed = true;
};

const restoreConsole = () => {
    if (!expectedLogsSuppressed) {
        return;
    }

    console.warn = originalConsoleWarn;
    console.info = originalConsoleInfo;
    console.error = originalConsoleError;
    expectedLogsSuppressed = false;
};

export const cleanupDatabase = async () => {
    const database = mongoose.connection.db;
    if (!database) {
        return;
    }

    const collections = await database.collections();
    await Promise.all(collections.map((collection) => collection.deleteMany({})));
};

export const startE2EApp = async (
    suiteName: string,
    options: { socket?: boolean; seed?: boolean } = {},
): Promise<E2EContext> => {
    suppressExpectedLogs();

    const suiteMongoUri = await buildSuiteMongoUri(suiteName);
    const [{ createApp }, db] = await Promise.all([
        import("../../src/app.js") as Promise<{ createApp: CreateApp }>,
        import("../../src/shared/db/mongoose.js") as Promise<{
            connectDB: ConnectDB;
            disconnectDB: DisconnectDB;
        }>,
    ]);

    await db.connectDB(suiteMongoUri);
    await cleanupDatabase();

    let seedData: Awaited<ReturnType<typeof import("../../src/testing/e2e-seed.js").seedE2EDatabase>> | null = null;
    if (options.seed) {
        const { seedE2EDatabase } = await import("../../src/testing/e2e-seed.js");
        seedData = await seedE2EDatabase({ reset: false, skipApiSecretCheck: true });
    }

    const app = createApp();
    const server: Server = app.listen(0);
    let socketServer: ReturnType<InitializeSocketIO> | null = null;

    if (options.socket) {
        const { initializeSocketIO } = await import(
            "../../src/shared/socket/socket.server.js"
        );
        socketServer = initializeSocketIO(server);
    }

    await new Promise<void>((resolve) => {
        server.once("listening", resolve);
    });

    const address = server.address();
    if (!address || typeof address === "string") {
        throw new Error("Test server did not bind to a TCP port");
    }

    return {
        baseUrl: `http://127.0.0.1:${(address as AddressInfo).port}`,
        cleanupDatabase,
        seedData,
        close: async () => {
            if (socketServer) {
                await new Promise<void>((resolve) => {
                    socketServer.close(() => resolve());
                });
            } else {
                await new Promise<void>((resolve, reject) => {
                    server.close((error) => (error ? reject(error) : resolve()));
                });
            }

            await cleanupDatabase();
            await db.disconnectDB();
            restoreConsole();
        },
    };
};

export const readJson = async <T>(response: Response): Promise<T> => {
    const text = await response.text();
    return (text ? JSON.parse(text) : {}) as T;
};

export const requestJson = async (
    context: E2EContext,
    path: string,
    options: {
        method?: string;
        body?: unknown;
        headers?: Record<string, string>;
    } = {},
) => {
    return fetch(`${context.baseUrl}${path}`, {
        method: options.method ?? "POST",
        headers: {
            "content-type": "application/json",
            ...options.headers,
        },
        body: options.body === undefined ? undefined : JSON.stringify(options.body),
    });
};

export const authHeaders = (accessToken: string) => ({
    authorization: `Bearer ${accessToken}`,
});

const uniqueId = () => `${Math.random().toString(36).slice(2, 12)}`;

export const createTestUser = (prefix = "e2e"): TestUserInput => {
    const id = uniqueId();

    return {
        username: `${prefix}_${id}`,
        password: "Password123!",
        email: `${prefix}.${id}@example.com`,
        firstName: "E2E",
        lastName: "Tester",
    };
};

const decodeJwtPayload = (token: string) => {
    const [, payload] = token.split(".");
    assert.ok(payload, "Expected access token to contain a payload");

    return JSON.parse(Buffer.from(payload, "base64url").toString("utf8")) as {
        userId: string;
        username: string;
    };
};

export const registerAndLogin = async (
    context: E2EContext,
    prefix = "e2e_user",
): Promise<AuthenticatedUser> => {
    const user = createTestUser(prefix);

    const registerResponse = await requestJson(context, "/api/auth/register", {
        body: user,
    });
    assert.equal(registerResponse.status, 201);

    const loginResponse = await requestJson(context, "/api/auth/login", {
        body: {
            username: user.username,
            password: user.password,
        },
    });
    const loginBody = await readJson<{
        accessToken: string;
        refreshToken: string;
    }>(loginResponse);

    assert.equal(loginResponse.status, 200);
    assert.ok(loginBody.accessToken);
    assert.ok(loginBody.refreshToken);

    const payload = decodeJwtPayload(loginBody.accessToken);

    return {
        user,
        userId: payload.userId,
        accessToken: loginBody.accessToken,
        refreshToken: loginBody.refreshToken,
    };
};

export const createFriendship = async (
    context: E2EContext,
    from: AuthenticatedUser,
    to: AuthenticatedUser,
) => {
    const requestResponse = await requestJson(context, "/api/friends/requests", {
        body: {
            to: to.userId,
            message: "hello",
        },
        headers: authHeaders(from.accessToken),
    });
    const requestBody = await readJson<{ request: { _id: string } }>(requestResponse);

    assert.equal(requestResponse.status, 200);
    assert.ok(requestBody.request?._id);

    const acceptResponse = await requestJson(
        context,
        `/api/friends/requests/${requestBody.request._id}/accept`,
        {
            headers: authHeaders(to.accessToken),
        },
    );

    assert.equal(acceptResponse.status, 200);

    return requestBody.request;
};
