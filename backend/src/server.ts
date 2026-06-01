import { createServer } from "http";
import app from "./app.js";
import { ensureMediaBuckets } from "./shared/config/minio.js";
import { envConfig } from "./shared/config/env.js";
import { connectDB } from "./shared/db/mongoose.js";
import { initializeSocketIO } from "./shared/socket/socket.server.js";

const httpServer = createServer(app);

const PORT = envConfig.port;
const failOnMediaBootstrapError =
    envConfig.nodeEnv === "production" ||
    process.env.MINIO_STRICT_STARTUP === "true" ||
    process.env.IS_E2E === "true";

const startHttpServer = () => {
    httpServer.listen(PORT, () => {
        console.log(`Server is running on port localhost:${PORT}`);
        console.log(
            `Swagger documentation available at http://localhost:${PORT}/api-docs`,
        );
    });
};

const bootstrap = async () => {
    try {
        await connectDB();
        console.log("Connected to the database successfully");

        await ensureMediaBuckets().catch((error) => {
            if (failOnMediaBootstrapError) {
                // E2E hoặc production: bucket PHẢI tồn tại, không cho phép bỏ qua
                throw error;
            }
            // Dev mode: cảnh báo nhưng vẫn chạy (MinIO có thể chưa start)
            console.warn(
                "MinIO is unavailable. Media features may fail until MinIO is running.",
            );
        });

        console.log("Media storage bootstrap completed (buckets ready)");

        initializeSocketIO(httpServer);
        console.log("Socket.IO initialized");

        startHttpServer();
    } catch (error) {
        console.error("Server bootstrap failed:", error);
        if (process.env.IS_E2E === "true") {
            // E2E: không cho phép chạy với MinIO hỏng — thoát hẳn để Docker restart
            console.error("[E2E] Exiting because MinIO bucket setup failed.");
            process.exit(1);
        }
        // Dev: vẫn start HTTP để dev có thể debug /api-docs
        startHttpServer();
    }
};

void bootstrap();

export default app;
