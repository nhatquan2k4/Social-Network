import express from "express";
import { createServer } from "http";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors, { CorsOptions } from "cors";
import swaggerUi from "swagger-ui-express";
import authRoutes from "./routes/auth/auth.route";
import userRoutes from "./routes/users/users.route";
import friendRoutes from "./routes/friends/friends.route";
import messageRoutes from "./routes/messages/messages.route";
import conversationRoutes from "./routes/conversations/conversations.route";
import mediaRoutes from "./routes/media/media.route";
import postRoutes from "./routes/posts/posts.route";
import notificationRoutes from "./routes/notifications/notifications.route";
import { swaggerSpec } from "./shared/config/swagger";
import { ensureMediaBuckets } from "./shared/config/minio";
import { connectDB } from "./shared/db/mongoose";
import { envConfig } from "./shared/config/env";
import { errorHandler } from "./shared/errors/error-handler";
import { initializeSocketIO } from "./shared/socket/socket.server";

dotenv.config();

const app = express();
const httpServer = createServer(app);

const PORT = envConfig.port;
const failOnMediaBootstrapError =
	process.env.NODE_ENV === "production" ||
	process.env.MINIO_STRICT_STARTUP === "true";

const allowedOrigins = [
	"http://localhost:3000",
	"http://127.0.0.1:3000",
	"http://localhost:8080",
	"http://127.0.0.1:8080",
	...(process.env.CORS_ORIGIN
		? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
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

		return callback(new Error(`CORS blocked for origin: ${origin}`));
	},
	credentials: true,
};

app.use(cors(corsOptions));
app.use(express.json());
app.use(cookieParser());

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get("/api-docs.json", (req, res) => {
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

app.get("/", (req, res) => {
	res.send("Hello World!");
});

app.use(errorHandler);

const startHttpServer = () => {
	app.listen(PORT, () => {
		console.log(`Server is running on port localhost:${PORT}`);
		console.log(
			`Swagger documentation available at http://localhost:${PORT}/api-docs`,
		);
	});
};

connectDB()
	.then(() => {
		console.log("Connected to the database successfully");
		return ensureMediaBuckets().catch((error) => {
			if (failOnMediaBootstrapError) {
				throw error;
			}

			console.warn(
				"MinIO is unavailable. Media features may fail until MinIO is running.",
			);
		});
	})
	.then(() => {
		console.log("Media storage bootstrap completed");

		initializeSocketIO(httpServer);
		console.log("Socket.IO initialized");

		httpServer.listen(PORT, () => {
			console.log(`Server is running on port localhost:${PORT}`);
			console.log(
				`Swagger documentation available at http://localhost:${PORT}/api-docs`,
			);
		});
	})
	.catch((error) => {
		console.error("Server bootstrap failed (continuing to start HTTP server):", error);
		// Start the HTTP server anyway so developer can access routes like /api-docs
		// while DB or MinIO is unavailable. Remove or guard this in production.
		startHttpServer();
	});

export default app;