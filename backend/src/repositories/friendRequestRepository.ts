import FriendRequest from '../models/friendRequest';
import { Types } from 'mongoose';

export class FriendRequestRepository {
    async findBetweenUsers(from: Types.ObjectId, to: Types.ObjectId) {
        return await FriendRequest.findOne({
            $or: [
                { from, to },
                { from: to, to: from }
            ]
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
        return await FriendRequest.find({ from: userId })
            .populate('to', populateFields)
            .lean();
    }

    async findReceivedByUserId(userId: Types.ObjectId, populateFields: string) {
        return await FriendRequest.find({ to: userId })
            .populate('from', populateFields)
            .lean();
    }
}
