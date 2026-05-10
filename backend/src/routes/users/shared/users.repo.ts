import { UserModel as User } from './users.model.js';
import { Types } from 'mongoose';

export class UserRepository {
    async findByUsername(username: string) {
        return await User.findOne({ username });
    }

    async findByEmail(email: string) {
        return await User.findOne({ email: email.toLowerCase().trim() });
    }

    async findById(userId: string | Types.ObjectId) {
        return await User.findById(userId);
    }

    async findByIdWithoutPassword(userId: string | Types.ObjectId) {
        return await User.findById(userId).select('-hashedPassword');
    }

    async exists(userId: string | Types.ObjectId) {
        return await User.exists({ _id: userId });
    }

    async create(userData: {
        username: string;
        hashedPassword: string;
        email: string;
        displayName: string;
        isEmailVerified?: boolean;
        emailVerifiedAt?: Date | null;
        emailVerificationSentAt?: Date | null;
    }) {
        const newUser = new User(userData);
        return await newUser.save();
    }

    async markEmailVerified(userId: string | Types.ObjectId) {
        return await User.findByIdAndUpdate(
            userId,
            {
                $set: {
                    isEmailVerified: true,
                    emailVerifiedAt: new Date(),
                },
                $unset: {
                    emailVerificationSentAt: 1,
                },
            },
            { new: true },
        );
    }

    async setEmailVerificationSentAt(userId: string | Types.ObjectId, sentAt: Date) {
        return await User.findByIdAndUpdate(
            userId,
            {
                $set: {
                    emailVerificationSentAt: sentAt,
                },
            },
            { new: true },
        );
    }

    async findByIdWithFields(userId: string | Types.ObjectId, fields: string) {
        return await User.findById(userId).select(fields).lean();
    }

    async findProfileById(userId: string | Types.ObjectId) {
        return await User.findById(userId)
            .select('_id username displayName avatarUrl bio createdAt updatedAt')
            .lean();
    }

    async updateProfile(
        userId: string | Types.ObjectId,
        setData: Record<string, unknown>,
        unsetFields: string[],
    ) {
        const updateQuery: Record<string, unknown> = {};

        if (Object.keys(setData).length > 0) {
            updateQuery.$set = setData;
        }

        if (unsetFields.length > 0) {
            const unsetQuery: Record<string, 1> = {};
            unsetFields.forEach((field) => {
                unsetQuery[field] = 1;
            });
            updateQuery.$unset = unsetQuery;
        }

        return await User.findByIdAndUpdate(userId, updateQuery, { new: true }).select('-hashedPassword');
    }

    async updateAvatar(
        userId: string | Types.ObjectId,
        avatarData: { avatarUrl: string; avatarPublicId: string; avatarBucket: string; avatarObjectKey: string },
    ) {
        return await User.findByIdAndUpdate(
            userId,
            {
                $set: {
                    avatarUrl: avatarData.avatarUrl,
                    avatarPublicId: avatarData.avatarPublicId,
                    avatarBucket: avatarData.avatarBucket,
                    avatarObjectKey: avatarData.avatarObjectKey,
                },
            },
            { new: true },
        ).select('-hashedPassword');
    }
    async searchByDisplayName(
        name: string,
        currentUserId: Types.ObjectId,
        page: number,
        limit: number,
    ) {
        const regex = new RegExp(name, 'i');
        const skip = (page - 1) * limit;

        const [users, total] = await Promise.all([
            User.find({
                displayName: { $regex: regex },
                _id: { $ne: currentUserId },
            })
                .select('_id username displayName avatarUrl bio')
                .sort({ displayName: 1, _id: 1 })
                .skip(skip)
                .limit(limit)
                .lean(),
            User.countDocuments({
                displayName: { $regex: regex },
                _id: { $ne: currentUserId },
            }),
        ]);

        return { users, total };
    }

    async updateLastSeenAt(userId: string | Types.ObjectId, date: Date) {
        return await User.updateOne(
            { _id: userId },
            { $set: { lastSeenAt: date } },
        );
    }

    async getLastSeenBatch(userIds: string[]): Promise<Map<string, Date | null>> {
        const objectIds = userIds.map((id) => new Types.ObjectId(id));
        const users = await User.find({ _id: { $in: objectIds } })
            .select('_id lastSeenAt')
            .lean();

        const map = new Map<string, Date | null>();
        for (const u of users) {
            map.set(
                (u._id as Types.ObjectId).toString(),
                (u as Record<string, unknown>).lastSeenAt as Date | null ?? null,
            );
        }
        return map;
    }

    async updatePassword(userId: string | Types.ObjectId, hashedPassword: string) {
        return await User.findByIdAndUpdate(
            userId,
            { $set: { hashedPassword } },
            { new: true },
        );
    }
}
