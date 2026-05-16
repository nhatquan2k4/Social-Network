import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcrypt";
import { UserModel as User } from "../routes/users/shared/users.model.js";

dotenv.config();

const connectionString =
  process.env.MONGODB_CONNECTIONSTRING ||
  "mongodb://localhost:27017/social_network";

async function seed() {
  try {
    await mongoose.connect(connectionString);

    const hashedPassword = await bcrypt.hash("Password123!", 10);

    // ── 1. Seed user thường ──────────────────────────────────────
    const seedUsername = "seed_user";
    const seedEmail = "seed.user@example.com";

    const existingSeedUser = await User.findOne({
      $or: [{ username: seedUsername }, { email: seedEmail }],
    });

    if (existingSeedUser) {
      console.log("Seed user already exists, skipping.");
    } else {
      await User.create({
        username: seedUsername,
        hashedPassword,
        email: seedEmail,
        displayName: "Seed User",
        bio: "Seed data for local MongoDB testing.",
      });
      console.log("Seed user inserted successfully.");
    }

    // ── 2. Seed admin ────────────────────────────────────────────
    const adminUsername = "admin";
    const adminEmail = "admin@example.com";

    const existingAdmin = await User.findOne({
      $or: [{ username: adminUsername }, { email: adminEmail }],
    });

    if (existingAdmin) {
      // Đảm bảo role = admin nếu tài khoản đã tồn tại nhưng chưa có role
      if (existingAdmin.role !== "admin") {
        existingAdmin.role = "admin";
        await existingAdmin.save();
        console.log("Existing admin account updated to role=admin.");
      } else {
        console.log("Admin account already exists, skipping.");
      }
    } else {
      await User.create({
        username: adminUsername,
        hashedPassword,
        email: adminEmail,
        displayName: "Admin",
        bio: "System administrator account.",
        role: "admin",
      });
      console.log("Admin account inserted successfully.");
    }
  } catch (error) {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
}

void seed();
