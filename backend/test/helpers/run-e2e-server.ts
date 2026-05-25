import { MongoMemoryServer } from "mongodb-memory-server";
import dotenv from "dotenv";
import mongoose from "mongoose";
import { createApp } from "../../src/app.js";
import { connectDB } from "../../src/shared/db/mongoose.js";
import { initializeSocketIO } from "../../src/shared/socket/socket.server.js";
import { seed } from "../../src/scripts/seed.js";

dotenv.config();

// Turn off real SMTP settings
process.env.SMTP_HOST = "";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";
process.env.IS_E2E = "true";

async function startServer() {
    console.log("🚀 Starting In-Memory MongoDB Server...");
    const mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    console.log(`📡 In-Memory MongoDB is running at: ${mongoUri}`);

    console.log("🔌 Connecting Mongoose to in-memory database...");
    await connectDB(mongoUri);
    console.log("✅ Mongoose connected successfully!");

    console.log("🌱 Seeding in-memory database with test data...");
    await seed(mongoUri);
    console.log("✅ In-memory database seeded successfully!");

    console.log("⚡ Creating Express application...");
    const app = createApp();

    // Thêm endpoint reset database dành riêng cho E2E
    app.post("/api/test/reset", async (req, res) => {
        try {
            console.log("🧹 E2E: Resetting in-memory database...");
            const collections = mongoose.connection.collections;
            for (const key in collections) {
                const collection = collections[key];
                await collection.deleteMany({});
            }
            console.log("🌱 E2E: Re-seeding in-memory database...");
            await seed(mongoUri);
            console.log("✅ E2E: In-memory database reset & seeded successfully!");
            res.status(200).json({ message: "Database reset successfully" });
        } catch (error) {
            console.error("❌ E2E: Failed to reset database:", error);
            res.status(500).json({ error: "Failed to reset database", details: (error instanceof Error) ? error.message : String(error) });
        }
    });

    const PORT = 5001;
    const server = app.listen(PORT, "0.0.0.0", () => {
        console.log(`\n===========================================`);
        console.log(`🎉 LOCAL E2E BACKEND SERVER IS RUNNING 🎉`);
        console.log(`🌐 API Endpoint: http://localhost:${PORT}/api`);
        console.log(`🔌 WebSockets:  ws://localhost:${PORT}`);
        console.log(`===========================================\n`);
    });

    console.log("🔌 Initializing WebSockets (Socket.IO) server...");
    initializeSocketIO(server);
    console.log("✅ Socket.IO server initialized successfully!");

    // Keep process alive and handle termination cleanly
    const shutdown = async () => {
        console.log("\n🛑 Shutting down E2E backend server...");
        server.close();
        await mongoServer.stop();
        console.log("👋 Done. Goodbye!");
        process.exit(0);
    };

    process.on("SIGINT", shutdown);
    process.on("SIGTERM", shutdown);
}

startServer().catch((error) => {
    console.error("❌ Failed to start E2E backend server:", error);
    process.exit(1);
});
