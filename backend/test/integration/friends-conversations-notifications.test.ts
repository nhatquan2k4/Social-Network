import assert from "node:assert/strict";
import { after, before, beforeEach, describe, it } from "node:test";
import { Types } from "mongoose";
import {
    buildSuiteMongoUri,
    cleanupDatabase,
    skipDbE2E,
} from "../helpers/e2e.js";
import {
    FriendModel,
} from "../../src/routes/friends/shared/friends.model.js";
import {
    FriendRepository,
    FriendRequestRepository,
} from "../../src/routes/friends/shared/friends.repo.js";
import { ConversationRepository } from "../../src/routes/conversations/shared/conversations.repo.js";
import { NotificationRepository } from "../../src/routes/notifications/notifications.repo.js";
import { UserRepository } from "../../src/routes/users/shared/users.repo.js";
import {
    connectDB,
    disconnectDB,
} from "../../src/shared/db/mongoose.js";

const userRepository = new UserRepository();

const createUser = async (prefix: string) => {
    const id = `${Date.now()}_${Math.random().toString(16).slice(2)}`;

    return userRepository.create({
        username: `${prefix}_${id}`,
        hashedPassword: "hashed-password",
        email: `${prefix}.${id}@example.com`,
        displayName: `${prefix} user`,
    });
};

describe("friends, conversations and notifications integration", { skip: skipDbE2E }, () => {
    before(async () => {
        await connectDB(await buildSuiteMongoUri("integration"));
        await FriendModel.syncIndexes();
        await cleanupDatabase();
    });

    beforeEach(async () => {
        await cleanupDatabase();
    });

    after(async () => {
        await cleanupDatabase();
        await disconnectDB();
    });

    it("enforces unique friend relationships and returns friend ids for both users", async () => {
        const friendRepository = new FriendRepository();
        const userA = await createUser("friend_unique_a");
        const userB = await createUser("friend_unique_b");

        const friendship = await friendRepository.create(userB._id, userA._id);
        assert.ok(friendship._id);

        await assert.rejects(
            () => friendRepository.create(userA._id, userB._id),
            /duplicate key/,
        );

        const sortedA = userA._id.toString() < userB._id.toString()
            ? userA._id.toString()
            : userB._id.toString();
        const sortedB = userA._id.toString() < userB._id.toString()
            ? userB._id.toString()
            : userA._id.toString();

        assert.ok(await friendRepository.findByUsers(sortedA, sortedB));
        assert.deepEqual(await friendRepository.getFriendIds(userA._id), [
            userB._id.toString(),
        ]);
        assert.deepEqual(await friendRepository.getFriendIds(userB._id), [
            userA._id.toString(),
        ]);
    });

    it("finds pending friend requests between users in either direction", async () => {
        const friendRequestRepository = new FriendRequestRepository();
        const userA = await createUser("request_a");
        const userB = await createUser("request_b");

        const request = await friendRequestRepository.create(
            userA._id,
            userB._id,
            "hello",
        );

        const fromAtoB = await friendRequestRepository.findBetweenUsers(
            userA._id,
            userB._id,
        );
        const fromBtoA = await friendRequestRepository.findBetweenUsers(
            userB._id,
            userA._id,
        );

        assert.equal(fromAtoB?._id.toString(), request._id.toString());
        assert.equal(fromBtoA?._id.toString(), request._id.toString());
    });

    it("looks up direct conversations and user conversation ids by participant", async () => {
        const conversationRepository = new ConversationRepository();
        const userA = await createUser("conversation_a");
        const userB = await createUser("conversation_b");

        const conversation = await conversationRepository.create({
            type: "direct",
            participants: [{ userId: userA._id }, { userId: userB._id }],
            lastMessageAt: new Date(),
        });

        const directAtoB = await conversationRepository.findDirectConversation(
            userA._id,
            userB._id,
        );
        const directBtoA = await conversationRepository.findDirectConversation(
            userB._id,
            userA._id,
        );
        const conversationIds = await conversationRepository.findUserConversationIds(
            userA._id,
        );

        assert.equal(directAtoB?._id.toString(), conversation._id.toString());
        assert.equal(directBtoA?._id.toString(), conversation._id.toString());
        assert.deepEqual(
            conversationIds.map((item: { _id: Types.ObjectId }) => item._id.toString()),
            [conversation._id.toString()],
        );
    });

    it("persists, queries, and marks notifications as read", async () => {
        const notificationRepository = new NotificationRepository();
        const recipient = await createUser("notification_recipient");
        const actor = await createUser("notification_actor");

        const older = await notificationRepository.create({
            recipientId: recipient._id,
            actorId: actor._id,
            type: "FRIEND_REQUEST",
            title: "Friend request",
            body: "Actor sent a request",
            entityType: "friend_request",
            entityId: "request-1",
        });
        const newer = await notificationRepository.create({
            recipientId: recipient._id,
            actorId: actor._id,
            type: "POST_COMMENTED",
            title: "Comment",
            body: "Actor commented",
            entityType: "post",
            entityId: "post-1",
            metadata: { commentId: "comment-1" },
        });

        const unread = await notificationRepository.findByRecipient(
            recipient._id,
            0,
            10,
            true,
        );

        assert.deepEqual(
            unread.map((notification: { _id: Types.ObjectId }) => notification._id.toString()),
            [newer._id.toString(), older._id.toString()],
        );
        assert.equal(await notificationRepository.countByRecipient(recipient._id, true), 2);

        const marked = await notificationRepository.markRead(newer._id.toString(), recipient._id);
        assert.equal(marked?.isRead, true);
        assert.ok(marked?.readAt);
        assert.equal(await notificationRepository.countByRecipient(recipient._id, true), 1);

        assert.equal(await notificationRepository.markAllRead(recipient._id), 1);
        assert.equal(await notificationRepository.countByRecipient(recipient._id, true), 0);
    });
});
