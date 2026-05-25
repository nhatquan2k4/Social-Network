import { MongoMemoryServer } from "mongodb-memory-server";
import dotenv from "dotenv";
import mongoose from "mongoose";

dotenv.config();

process.env.NODE_ENV = "test";
process.env.E2E_TEST_API = "true";
process.env.E2E_EXTERNAL_SERVICES = "mock";
process.env.IS_E2E = "true";
process.env.SMTP_HOST = "";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";

async function startServer() {
    console.log("Starting in-memory MongoDB for FE E2E...");
    const mongoServer = await MongoMemoryServer.create({
        instance: {
            dbName: "social_network_e2e_test",
        },
    });
    const mongoUri = mongoServer.getUri("social_network_e2e_test");
    console.log(`In-memory MongoDB URI: ${mongoUri}`);

    const [{ createApp }, db, socket, seed] = await Promise.all([
        import("../../src/app.js") as Promise<typeof import("../../src/app.js")>,
        import("../../src/shared/db/mongoose.js") as Promise<
            typeof import("../../src/shared/db/mongoose.js")
        >,
        import("../../src/shared/socket/socket.server.js") as Promise<
            typeof import("../../src/shared/socket/socket.server.js")
        >,
        import("../../src/testing/e2e-seed.js") as Promise<
            typeof import("../../src/testing/e2e-seed.js")
        >,
    ]);

    await db.connectDB(mongoUri);
    console.log("Mongoose connected to in-memory database.");

    await seed.seedE2EDatabase({
        runId: "server_start",
        scenario: "bootstrap",
        reset: true,
    });
    console.log("Initial E2E seed completed. FE tests can reseed via POST /api/test/seed.");

    const app = createApp();
    const port = Number(process.env.E2E_PORT || 5001);
    const server = app.listen(port, "0.0.0.0", () => {
        console.log("");
        console.log("===========================================");
        console.log("LOCAL FE E2E BACKEND SERVER IS RUNNING");
        console.log(`API endpoint: http://localhost:${port}/api`);
        console.log(`Seed endpoint: http://localhost:${port}/api/test/seed`);
        console.log(`Reset endpoint: http://localhost:${port}/api/test/reset`);
        console.log(`WebSocket endpoint: ws://localhost:${port}`);
        console.log("===========================================");
        console.log("");
    });

    socket.initializeSocketIO(server);
    console.log("Socket.IO initialized.");

    const shutdown = async () => {
        console.log("\nShutting down FE E2E backend server...");
        await new Promise<void>((resolve) => server.close(() => resolve()));
        await mongoose.disconnect().catch(() => undefined);
        await mongoServer.stop();
        console.log("Done.");
        process.exit(0);
    };

    process.on("SIGINT", shutdown);
    process.on("SIGTERM", shutdown);
}

startServer().catch((error) => {
    console.error("Failed to start FE E2E backend server:", error);
    process.exit(1);
});
