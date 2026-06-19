import { MongoMemoryServer } from "mongodb-memory-server";
import dotenv from "dotenv";
import mongoose from "mongoose";
import path from "path";

// Khi chạy local: nạp .env.e2e trước (nếu có), sau đó .env gốc làm dự phòng
// Khi chạy trong Docker: docker-compose.e2e.yml đã inject sẵn qua env_file → dotenv không nạp được gì thêm (bình thường)
dotenv.config({ path: path.resolve(process.cwd(), ".env.e2e"), override: false });
dotenv.config({ override: false });

// Nếu các biến môi trường thiết yếu chưa được nạp, gán mặc định dự phòng để tránh crash hệ thống
if (!process.env.E2E_EXTERNAL_SERVICES) {
    process.env.E2E_EXTERNAL_SERVICES = "mock";
}

async function startServer() {
    // ── Xác định URI MongoDB ────────────────────────────────────────────────────
    //
    // Chế độ 1 — Docker E2E:
    //   E2E_MONGO_URI được set bởi docker-compose.e2e.yml.
    //   Dùng MongoDB container thật (mongodb-e2e:27017). Không tạo In-Memory server.
    //
    // Chế độ 2 — Local (mặc định):
    //   E2E_MONGO_URI không được set.
    //   Tạo MongoDB In-Memory (mongodb-memory-server) để không cần cài MongoDB.
    //
    let mongoUri: string;
    let mongoServer: MongoMemoryServer | undefined;

    const externalMongoUri = process.env.E2E_MONGO_URI?.trim();

    if (externalMongoUri) {
        // ── Chế độ Docker E2E: dùng URI MongoDB từ biến môi trường ───────────
        mongoUri = externalMongoUri;
        console.log(`[E2E] Chế độ Docker — Kết nối MongoDB tại: ${mongoUri}`);
    } else {
        // ── Chế độ Local: tạo MongoDB In-Memory ──────────────────────────────
        console.log("[E2E] Chế độ Local — Khởi động MongoDB In-Memory...");
        mongoServer = await MongoMemoryServer.create({
            instance: {
                dbName: "social_network_e2e_test",
            },
        });
        mongoUri = mongoServer.getUri("social_network_e2e_test");
        console.log(`[E2E] MongoDB In-Memory URI: ${mongoUri}`);
    }

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
    console.log("[E2E] Mongoose đã kết nối database.");

    await seed.seedE2EDatabase({
        reset: true,
        skipApiSecretCheck: true,
    });
    console.log("[E2E] Seed dữ liệu khởi động hoàn tất. Flutter có thể reseed qua POST /api/test/seed.");

    const app = createApp();
    const port = Number(process.env.E2E_PORT || 5001);

    const server = app.listen(port, "0.0.0.0", () => {
        console.log("");
        console.log("===========================================");
        console.log("  FE E2E BACKEND SERVER ĐANG CHẠY");
        console.log(`  API:       http://localhost:${port}/api`);
        console.log(`  Health:    http://localhost:${port}/api/test/health`);
        console.log(`  WebSocket: ws://localhost:${port}`);
        console.log("===========================================");
        console.log("");
    });

    socket.initializeSocketIO(server);
    console.log("[E2E] Socket.IO đã khởi tạo.");

    const shutdown = async () => {
        console.log("\n[E2E] Đang tắt server...");
        await new Promise<void>((resolve) => server.close(() => resolve()));
        await mongoose.disconnect().catch(() => undefined);
        if (mongoServer) {
            await mongoServer.stop();
            console.log("[E2E] MongoDB In-Memory đã dừng.");
        }
        console.log("[E2E] Server đã tắt hoàn toàn.");
        process.exit(0);
    };

    process.on("SIGINT", shutdown);
    process.on("SIGTERM", shutdown);
}

startServer().catch((error) => {
    console.error("[E2E] Khởi động server thất bại:", error);
    process.exit(1);
});
