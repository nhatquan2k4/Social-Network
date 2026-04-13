import {
    FriendModel as Friend,
    FriendRequestModel as FriendRequest,
} from "./friends.model";
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
