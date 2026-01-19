import Friend from '../models/friend';
import { Types } from 'mongoose';

export class FriendRepository {
    async findByUsers(userA: string, userB: string) {
        return await Friend.findOne({ userA, userB });
    }

    async create(userA: Types.ObjectId, userB: Types.ObjectId) {
        return await Friend.create({ userA, userB });
    }

    async findAllByUserId(userId: Types.ObjectId) {
        return await Friend.find({
            $or: [
                { userA: userId },
                { userB: userId }
            ]
        })
        .populate('userA', 'username displayName avatarUrl')
        .populate('userB', 'username displayName avatarUrl')
        .lean();
    }
}
