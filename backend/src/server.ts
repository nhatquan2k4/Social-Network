import express from "express";
import dotenv from "dotenv";
import connectDB from "./libs/db";
import authRoutes from "./routes/authRoutes";
import cookieParser from "cookie-parser";
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

// middleware
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
    return ensureMediaBuckets();
  })
  .then(() => {
    console.log("MinIO buckets ready");

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