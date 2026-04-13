import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcrypt";
import { UserModel as User } from "../routes/users/shared/users.model";

dotenv.config();

const connectionString =
  process.env.MONGODB_CONNECTIONSTRING ||
  "mongodb://localhost:27017/social_network";

async function seed() {
  try {
    await mongoose.connect(connectionString);

    const username = "seed_user";
    const email = "seed.user@example.com";

    const existingUser = await User.findOne({
      $or: [{ username }, { email }],
    });

    if (existingUser) {
      console.log("Seed user already exists, skipping insert.");
      return;
    }

    const hashedPassword = await bcrypt.hash("Password123!", 10);

    await User.create({
      username,
      hashedPassword,
      email,
      displayName: "Seed User",
      bio: "Seed data for local MongoDB testing.",
    });

    console.log("Seed user inserted successfully.");
  } catch (error) {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
}

void seed();
