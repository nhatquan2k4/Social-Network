import { MongoMemoryServer } from "mongodb-memory-server";
import dotenv from "dotenv";
import { createApp } from "../../src/app.js";
import { connectDB } from "../../src/shared/db/mongoose.js";
import { initializeSocketIO } from "../../src/shared/socket/socket.server.js";

dotenv.config();

// Turn off real SMTP settings
process.env.SMTP_HOST = "";
process.env.SMTP_USER = "";
process.env.SMTP_PASS = "";

async function startServer() {
    console.log("🚀 Starting In-Memory MongoDB Server...");
    const mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    console.log(`📡 In-Memory MongoDB is running at: ${mongoUri}`);

    console.log("🔌 Connecting Mongoose to in-memory database...");
    await connectDB(mongoUri);
    console.log("✅ Mongoose connected successfully!");

    console.log("⚡ Creating Express application...");
    const app = createApp();
    
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
