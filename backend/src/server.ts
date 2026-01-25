import express from "express";
import dotenv from "dotenv";
import cors from "cors";
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

dotenv.config();

const app = express();

const PORT = process.env.PORT || 5001;

// CORS middleware - PHẢI ĐẶT TRƯỚC CÁC MIDDLEWARE KHÁC
app.use(cors({
  origin: true, // Cho phép tất cả origins trong development
  credentials: true, // Cho phép gửi cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Cookie'],
}));

// middleware
app.use(express.json());
app.use(cookieParser());

// Swagger documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// public routes
app.use("/api/auth", authRoutes);

// private routes
app.use("/api/users", userRoutes);
app.use("/api/friends", friendRoutes);
app.use("/api/messages", messageRoutes);
app.use("/api/conversations", conversationRoutes);

app.get("/", (req, res) => {
  res.send("Hello World!");
});

connectDB()
  .then(() => {
    console.log("Connected to the database successfully");
  })
  .catch((error) => {
    console.error("Database connection failed:", error);
  });

app.listen(PORT, () => {
  console.log(`Server is running on port localhost:${PORT}`);
  console.log(
    `Swagger documentation available at http://localhost:${PORT}/api-docs`,
  );
});