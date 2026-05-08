import {
    FriendModel as Friend,
    FriendRequestModel as FriendRequest,
    UserBlockModel as UserBlock,
} from "./friends.model.js";
import { Types } from "mongoose";

export class FriendRepository {
    async findByUsers(userA: string, userB: string) {
        return await Friend.findOne({ userA, userB });
    }

    async create(userA: Types.ObjectId, userB: Types.ObjectId) {
        return await Friend.create({ userA, userB });
    }

    async findAllByUserId(userId: Types.ObjectId) {
        return await Friend.find({
            $or: [{ userA: userId }, { userB: userId }],
        })
            .populate("userA", "username displayName avatarUrl")
            .populate("userB", "username displayName avatarUrl")
            .lean();
    }

    async countByUserId(userId: Types.ObjectId) {
        return await Friend.countDocuments({
            $or: [{ userA: userId }, { userB: userId }],
        });
    }

    async getFriendIds(userId: Types.ObjectId): Promise<string[]> {
        const friends = await Friend.find({
            $or: [{ userA: userId }, { userB: userId }],
        })
            .select("userA userB")
            .lean();

        const uid = userId.toString();
        return friends.map((f) => {
            const a = (f.userA as Types.ObjectId).toString();
            const b = (f.userB as Types.ObjectId).toString();
            return a === uid ? b : a;
        });
    }
}

export class FriendRequestRepository {
    async findBetweenUsers(from: Types.ObjectId, to: Types.ObjectId) {
        return await FriendRequest.findOne({
            $or: [{ from, to }, { from: to, to: from }],
        });
    }

    async create(from: Types.ObjectId, to: Types.ObjectId, message?: string) {
        return await FriendRequest.create({ from, to, message });
    }

    async findById(requestId: string) {
        return await FriendRequest.findById(requestId);
    }

    async deleteById(requestId: string) {
        return await FriendRequest.findByIdAndDelete(requestId);
    }

    async findSentByUserId(userId: Types.ObjectId, populateFields: string) {
        return await FriendRequest.find({ from: userId }).populate("to", populateFields).lean();
    }

    async findReceivedByUserId(userId: Types.ObjectId, populateFields: string) {
        return await FriendRequest.find({ to: userId })
            .populate("from", populateFields)
            .lean();
    }
}

export class BlockRepository {
    async findByUsers(blockerId: string | Types.ObjectId, blockedId: string | Types.ObjectId) {
        return await UserBlock.findOne({ blockerId, blockedId });
    }

    async findBetweenUsers(userA: string | Types.ObjectId, userB: string | Types.ObjectId) {
        return await UserBlock.findOne({
            $or: [
                { blockerId: userA, blockedId: userB },
                { blockerId: userB, blockedId: userA },
            ],
        });
    }

    async create(blockerId: Types.ObjectId, blockedId: Types.ObjectId) {
        return await UserBlock.create({ blockerId, blockedId });
    }

    async deleteByUsers(blockerId: Types.ObjectId, blockedId: string | Types.ObjectId) {
        return await UserBlock.findOneAndDelete({ blockerId, blockedId });
    }

    async findBlockedByUserId(blockerId: Types.ObjectId) {
        return await UserBlock.find({ blockerId })
            .populate("blockedId", "_id username displayName avatarUrl bio")
            .sort({ createdAt: -1 })
            .lean();
    }
}
