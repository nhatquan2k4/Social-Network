import express from "express";
import cookieParser from "cookie-parser";
import cors, { CorsOptions } from "cors";
import swaggerUi from "swagger-ui-express";
import authRoutes from "./routes/auth/auth.route.js";
import userRoutes from "./routes/users/users.route.js";
import friendRoutes from "./routes/friends/friends.route.js";
import messageRoutes from "./routes/messages/messages.route.js";
import conversationRoutes from "./routes/conversations/conversations.route.js";
import mediaRoutes from "./routes/media/media.route.js";
import postRoutes from "./routes/posts/posts.route.js";
import notificationRoutes from "./routes/notifications/notifications.route.js";
import adminRoutes from "./routes/admin/admin.route.js";
import testRoutes from "./routes/test/test.route.js";
import { envConfig } from "./shared/config/env.js";
import { swaggerSpec } from "./shared/config/swagger.js";
import { errorHandler } from "./shared/errors/error-handler.js";

const allowedOrigins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    ...(envConfig.corsOrigins
        ? envConfig.corsOrigins.split(",").map((origin) => origin.trim())
        : []),
];

const localDevOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i;

const corsOptions: CorsOptions = {
    origin: (origin, callback) => {
        if (!origin) {
            return callback(null, true);
        }

        if (allowedOrigins.includes(origin) || localDevOriginPattern.test(origin)) {
            return callback(null, true);
        }

        return callback(new Error(`CORS đã chặn origin: ${origin}`));
    },
    credentials: true,
};

export const createApp = () => {
    const app = express();

    app.use(cors(corsOptions));
    app.use(express.json());
    app.use((req, res, next) => {
        console.log(`📡 [Express Request] ${req.method} ${req.url}`);
        if (req.body && Object.keys(req.body).length > 0) {
            console.log(`   Body: ${JSON.stringify(req.body)}`);
        }
        res.on('finish', () => {
            console.log(`📡 [Express Response] ${req.method} ${req.url} - Status: ${res.statusCode}`);
        });
        next();
    });
    app.use(cookieParser());

    app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
    app.get("/api-docs.json", (_req, res) => {
        res.json(swaggerSpec);
    });

    app.use("/api/auth", authRoutes);
    app.use("/api/users", userRoutes);
    app.use("/api/friends", friendRoutes);
    app.use("/api/messages", messageRoutes);
    app.use("/api/conversations", conversationRoutes);
    app.use("/api/media", mediaRoutes);
    app.use("/api/posts", postRoutes);
    app.use("/api/notifications", notificationRoutes);
    app.use("/api/admin", adminRoutes);
    if (process.env.E2E_API_SECRET) {
        app.use("/api/test", testRoutes);
    }

    app.get("/", (_req, res) => {
        res.send("Hello World!");
    });

    app.use(errorHandler);

    return app;
};

export default createApp();
