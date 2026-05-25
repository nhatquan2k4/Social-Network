import bcrypt from 'bcrypt';
import mongoose, { Types } from 'mongoose';
import { UserModel } from '../routes/users/shared/users.model.js';
import { FriendModel, FriendRequestModel } from '../routes/friends/shared/friends.model.js';
import { ConversationModel } from '../routes/conversations/shared/conversations.model.js';
import { MessageModel } from '../routes/messages/shared/messages.model.js';
import { PostModel } from '../routes/posts/shared/posts.model.js';
import { NotificationModel } from '../routes/notifications/notifications.model.js';

const TEST_PASSWORD = 'Password123!';

export interface E2ESeedOptions {
    runId?: string;
    scenario?: string;
    reset?: boolean;
}

const normalizeSeedPart = (value: string | undefined, fallback: string) => {
    const normalized = String(value || '')
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9_-]/g, '_')
        .replace(/_+/g, '_')
        .replace(/^_+|_+$/g, '');

    return normalized || fallback;
};

const makeRunId = (value?: string) => {
    const fallback = `run_${Date.now()}_${Math.random().toString(16).slice(2, 8)}`;
    return normalizeSeedPart(value, fallback).slice(0, 48);
};

const getDatabaseName = () => mongoose.connection.db?.databaseName || '';

export const assertE2ETestApiEnabled = () => {
    if (process.env.E2E_TEST_API !== 'true') {
        throw new Error('E2E test API is disabled');
    }
};

const assertSafeDatabase = () => {
    assertE2ETestApiEnabled();

    const databaseName = getDatabaseName().toLowerCase();
    if (!databaseName.includes('test') && !databaseName.includes('e2e')) {
        throw new Error(
            `Refusing to mutate non-test database "${databaseName || '<unknown>'}"`,
        );
    }
};

export const resetE2EDatabase = async () => {
    assertSafeDatabase();

    const collections = Object.values(mongoose.connection.collections);
    await Promise.all(collections.map((collection) => collection.deleteMany({})));
};

const createUser = async (input: {
    username: string;
    email: string;
    displayName: string;
    hashedPassword: string;
    role?: 'user' | 'admin';
    bio?: string;
    avatarUrl?: string;
}) => {
    return UserModel.create({
        username: input.username,
        email: input.email,
        displayName: input.displayName,
        hashedPassword: input.hashedPassword,
        role: input.role ?? 'user',
        bio: input.bio,
        avatarUrl: input.avatarUrl,
        isEmailVerified: true,
        emailVerifiedAt: new Date(),
    });
};

export const seedE2EDatabase = async (options: E2ESeedOptions = {}) => {
    assertSafeDatabase();

    if (options.reset !== false) {
        await resetE2EDatabase();
    }

    const scenario = normalizeSeedPart(options.scenario, 'social_network');
    const runId = makeRunId(options.runId);
    const prefix = `e2e_${scenario}_${runId}`;
    const hashedPassword = await bcrypt.hash(TEST_PASSWORD, 10);
    const now = new Date();

    const primaryUser = await createUser({
        username: `${prefix}_user`,
        email: `${prefix}.user@example.test`,
        displayName: `E2E User ${runId}`,
        hashedPassword,
        bio: 'Primary E2E account',
    });

    const adminUser = await createUser({
        username: `${prefix}_admin`,
        email: `${prefix}.admin@example.test`,
        displayName: `E2E Admin ${runId}`,
        hashedPassword,
        role: 'admin',
        bio: 'Admin target for E2E search and friend request flow',
    });

    const friendUser = await createUser({
        username: `${prefix}_friend`,
        email: `${prefix}.friend@example.test`,
        displayName: `E2E Friend ${runId}`,
        hashedPassword,
        bio: 'Accepted friend for E2E chat flow',
    });

    const requesterUser = await createUser({
        username: `${prefix}_requester`,
        email: `${prefix}.requester@example.test`,
        displayName: `E2E Requester ${runId}`,
        hashedPassword,
        bio: 'Pending requester for notifications flow',
    });

    const friendship = await FriendModel.create({
        userA: primaryUser._id,
        userB: friendUser._id,
    });

    const conversation = await ConversationModel.create({
        type: 'direct',
        participants: [
            { userId: primaryUser._id },
            { userId: friendUser._id },
        ],
        lastMessageAt: now,
        seenBy: [primaryUser._id],
        unreadCounts: {
            [primaryUser._id.toString()]: 1,
            [friendUser._id.toString()]: 0,
        },
    });

    const firstMessage = await MessageModel.create({
        conversationId: conversation._id,
        senderId: friendUser._id,
        content: `Seeded E2E hello from ${friendUser.username}`,
        readBy: [{ userId: friendUser._id }],
    });

    conversation.lastMessage = {
        _id: firstMessage._id.toString(),
        content: firstMessage.content,
        senderId: firstMessage.senderId as Types.ObjectId,
        createdAt: firstMessage.createdAt,
    };
    conversation.lastMessageAt = firstMessage.createdAt;
    await conversation.save();

    const friendPost = await PostModel.create({
        authorId: friendUser._id,
        content: `Seeded E2E feed post ${runId}`,
        likes: [],
        comments: [
            {
                authorId: primaryUser._id,
                content: `Seeded E2E comment ${runId}`,
                createdAt: now,
                updatedAt: now,
            },
        ],
        commentsCount: 1,
    });

    const adminPost = await PostModel.create({
        authorId: adminUser._id,
        content: `Seeded admin announcement ${runId}`,
        likes: [],
        comments: [],
    });

    const pendingRequest = await FriendRequestModel.create({
        from: requesterUser._id,
        to: primaryUser._id,
        message: `Please accept E2E request ${runId}`,
    });

    await NotificationModel.create([
        {
            recipientId: primaryUser._id,
            actorId: requesterUser._id,
            type: 'FRIEND_REQUEST',
            title: 'Loi moi ket ban moi',
            body: 'Ban vua nhan duoc mot loi moi ket ban.',
            entityType: 'friend_request',
            entityId: pendingRequest._id.toString(),
            metadata: { requestId: pendingRequest._id.toString() },
            isRead: false,
        },
        {
            recipientId: primaryUser._id,
            actorId: friendUser._id,
            type: 'MESSAGE_NEW',
            title: 'Tin nhan moi',
            body: 'Ban co mot tin nhan moi.',
            entityType: 'conversation',
            entityId: conversation._id.toString(),
            metadata: { conversationId: conversation._id.toString() },
            isRead: false,
        },
        {
            recipientId: primaryUser._id,
            actorId: adminUser._id,
            type: 'POST_LIKED',
            title: 'Bai viet co tuong tac moi',
            body: 'da thich bai viet cua ban.',
            entityType: 'post',
            entityId: friendPost._id.toString(),
            metadata: { postId: friendPost._id.toString() },
            isRead: false,
        },
    ]);

    return {
        runId,
        scenario,
        password: TEST_PASSWORD,
        database: getDatabaseName(),
        users: {
            primary: {
                id: primaryUser._id.toString(),
                username: primaryUser.username,
                email: primaryUser.email,
                password: TEST_PASSWORD,
            },
            admin: {
                id: adminUser._id.toString(),
                username: adminUser.username,
                email: adminUser.email,
                password: TEST_PASSWORD,
            },
            friend: {
                id: friendUser._id.toString(),
                username: friendUser.username,
                email: friendUser.email,
                password: TEST_PASSWORD,
            },
            requester: {
                id: requesterUser._id.toString(),
                username: requesterUser.username,
                email: requesterUser.email,
                password: TEST_PASSWORD,
            },
        },
        entities: {
            friendshipId: friendship._id.toString(),
            conversationId: conversation._id.toString(),
            firstMessageId: firstMessage._id.toString(),
            friendPostId: friendPost._id.toString(),
            adminPostId: adminPost._id.toString(),
            pendingFriendRequestId: pendingRequest._id.toString(),
        },
    };
};
