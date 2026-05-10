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
    process.env.MINIO_STRICT_STARTUP === "true";

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
                throw error;
            }

            console.warn(
                "MinIO is unavailable. Media features may fail until MinIO is running.",
            );
        });

        console.log("Media storage bootstrap completed");

        initializeSocketIO(httpServer);
        console.log("Socket.IO initialized");

        startHttpServer();
    } catch (error) {
        console.error("Server bootstrap failed (continuing to start HTTP server):", error);
        // Start the HTTP server anyway so developers can access routes like /api-docs
        // while DB or MinIO is unavailable. Guard or remove this in production.
        startHttpServer();
    }
};

void bootstrap();

export default app;
