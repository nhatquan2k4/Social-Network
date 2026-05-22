import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcrypt";
import { UserModel as User } from "../routes/users/shared/users.model.js";
import { FriendModel as Friend } from "../routes/friends/shared/friends.model.js";
import { ConversationModel as Conversation } from "../routes/conversations/shared/conversations.model.js";
import { MessageModel as Message } from "../routes/messages/shared/messages.model.js";
import { PostModel as Post } from "../routes/posts/shared/posts.model.js";

dotenv.config();

const connectionString =
  process.env.MONGODB_CONNECTIONSTRING ||
  "mongodb://localhost:27017/social_network";

export async function seed(connString?: string) {
  try {
    const dbUri = connString || connectionString;
    const shouldConnect = mongoose.connection.readyState === 0;
    if (shouldConnect) {
      await mongoose.connect(dbUri);
    }

    const hashedPassword = await bcrypt.hash("Password123!", 10);

    // ── 1. Seed user thường (seed_user) ──────────────────────────────
    const seedUsername = "seed_user";
    const seedEmail = "seed.user@example.com";

    let seedUser = await User.findOne({
      $or: [{ username: seedUsername }, { email: seedEmail }],
    });

    if (seedUser) {
      console.log("Seed user already exists, skipping.");
    } else {
      seedUser = await User.create({
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

    let adminUser = await User.findOne({
      $or: [{ username: adminUsername }, { email: adminEmail }],
    });

    if (adminUser) {
      // Đảm bảo role = admin nếu tài khoản đã tồn tại nhưng chưa có role
      if (adminUser.role !== "admin") {
        adminUser.role = "admin";
        await adminUser.save();
        console.log("Existing admin account updated to role=admin.");
      } else {
        console.log("Admin account already exists, skipping.");
      }
    } else {
      adminUser = await User.create({
        username: adminUsername,
        hashedPassword,
        email: adminEmail,
        displayName: "Admin",
        bio: "System administrator account.",
        role: "admin",
      });
      console.log("Admin account inserted successfully.");
    }

    // ── 3. Seed bạn bè mẫu (seed_friend) ─────────────────────────
    const friendUsername = "seed_friend";
    const friendEmail = "seed.friend@example.com";

    let seedFriend = await User.findOne({
      $or: [{ username: friendUsername }, { email: friendEmail }],
    });

    if (seedFriend) {
      console.log("Seed friend account already exists, skipping.");
    } else {
      seedFriend = await User.create({
        username: friendUsername,
        hashedPassword,
        email: friendEmail,
        displayName: "Seed Friend",
        bio: "I am seed_user's friend! Ready to chat.",
        avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=seed_friend",
      });
      console.log("Seed friend account inserted successfully.");
    }

    // ── 4. Seed quan hệ bạn bè đã kết nối (accepted) ─────────────
    if (seedUser && seedFriend) {
      const existingFriendship = await Friend.findOne({
        $or: [
          { userA: seedUser._id, userB: seedFriend._id },
          { userA: seedFriend._id, userB: seedUser._id }
        ]
      });

      if (!existingFriendship) {
        await Friend.create({
          userA: seedUser._id,
          userB: seedFriend._id
        });
        console.log("Friend relation between seed_user and seed_friend created.");
      } else {
        console.log("Friend relation already exists, skipping.");
      }
    }

    // ── 5. Seed cuộc hội thoại direct ─────────────────────────────
    if (seedUser && seedFriend) {
      let conversation = await Conversation.findOne({
        type: "direct",
        "participants.userId": { $all: [seedUser._id, seedFriend._id] }
      });

      if (!conversation) {
        conversation = await Conversation.create({
          type: "direct",
          participants: [
            { userId: seedUser._id },
            { userId: seedFriend._id }
          ],
          lastMessageAt: new Date(),
          seenBy: [seedUser._id, seedFriend._id],
          unreadCounts: {
            [seedUser._id.toString()]: 0,
            [seedFriend._id.toString()]: 0
          }
        });
        console.log("Conversation between seed_user and seed_friend created.");
      } else {
        console.log("Conversation already exists, skipping.");
      }

      // ── 6. Seed tin nhắn mẫu ──────────────────────────────────────
      if (conversation) {
        const existingMessage = await Message.findOne({ conversationId: conversation._id });
        if (!existingMessage) {
          const sampleMessage = await Message.create({
            conversationId: conversation._id,
            senderId: seedFriend._id,
            content: "Xin chào! Mình là Seed Friend. Rất vui được kết bạn với bạn!",
            readBy: [{ userId: seedUser._id }]
          });

          // Cập nhật lastMessage cho Conversation
          conversation.lastMessage = {
            content: sampleMessage.content,
            senderId: sampleMessage.senderId,
            createdAt: sampleMessage.createdAt
          };
          conversation.lastMessageAt = sampleMessage.createdAt;
          await conversation.save();
          console.log("Sample message inserted and conversation updated.");
        } else {
          console.log("Sample message already exists, skipping.");
        }
      }
    }

    // ── 7. Seed bài đăng mẫu ──────────────────────────────────────
    if (seedFriend) {
      const existingFriendPost = await Post.findOne({ authorId: seedFriend._id });
      if (!existingFriendPost) {
        await Post.create({
          authorId: seedFriend._id,
          content: "Chào mọi người! Đây là bài đăng đầu tiên của mình trên mạng xã hội này. Chúc các bạn một ngày tốt lành! 😊",
          likes: seedUser ? [seedUser._id] : [],
          comments: seedUser ? [
            {
              authorId: seedUser._id,
              content: "Chào mừng bạn tham gia mạng xã hội nhé!",
              createdAt: new Date(),
              updatedAt: new Date()
            }
          ] : [],
          commentsCount: seedUser ? 1 : 0
        });
        console.log("Seed friend post created.");
      } else {
        console.log("Seed friend post already exists, skipping.");
      }
    }

    if (adminUser) {
      const existingAdminPost = await Post.findOne({ authorId: adminUser._id });
      if (!existingAdminPost) {
        await Post.create({
          authorId: adminUser._id,
          content: "📢 Thông báo hệ thống: Server Backend E2E đang chạy trơn tru với cơ sở dữ liệu In-Memory. Mọi chức năng Socket.IO, Feed và Friends đã sẵn sàng kiểm thử!",
          likes: [],
          comments: []
        });
        console.log("Admin announcement post created.");
      } else {
        console.log("Admin announcement post already exists, skipping.");
      }
    }

  } catch (error) {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  } finally {
    const shouldDisconnect = mongoose.connection.readyState !== 0 && !connString;
    if (shouldDisconnect) {
      await mongoose.disconnect();
    }
  }
}

import { fileURLToPath } from "url";
const isMain = process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];
if (isMain) {
  void seed();
}
