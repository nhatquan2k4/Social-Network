import express from "express";
import dotenv from "dotenv";
import connectDB from "./libs/db";
import authRoutes from "./routes/authRoutes";
import cookieParser from "cookie-parser";
import cors, { CorsOptions } from "cors";
import userRoutes from "./routes/userRoutes";
import { protectedRoute } from "./middlewares/authMiddleware";
import friendRoutes from "./routes/friendRoutes";
import messageRoutes from "./routes/messageRoutes";
import conversationRoutes from "./routes/conversationRoutes";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./config/swagger";
import mediaRoutes from "./routes/mediaRoutes";
import { ensureMediaBuckets } from "./config/minio";
import postRoutes from "./routes/postRoutes";
import notificationRoutes from "./routes/notificationRoutes";

dotenv.config();

const app = express();

const PORT = process.env.PORT || 5001;
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
    // Allow non-browser clients and local tools without Origin header.
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

// middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(cookieParser());

// Swagger documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get("/api-docs.json", (req, res) => {
  res.json(swaggerSpec);
});

// public routes
app.use("/api/auth", authRoutes);

// private routes
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

    app.listen(PORT, () => {
      console.log(`Server is running on port localhost:${PORT}`);
      console.log(
        `Swagger documentation available at http://localhost:${PORT}/api-docs`,
      );
    });
  })
  .catch((error) => {
    console.error("Server bootstrap failed:", error);
  });