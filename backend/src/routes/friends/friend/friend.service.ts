import { Types } from "mongoose";
import { FriendRepository } from "../shared/friends.repo";

export class FriendService {
    private friendRepository: FriendRepository;

    constructor() {
        this.friendRepository = new FriendRepository();
    }

    async getAllFriends(userId: Types.ObjectId) {
        const friendships = await this.friendRepository.findAllByUserId(userId);

        if (!friendships.length) {
            return [];
        }

        return friendships.map((friendship: any) =>
            friendship.userA._id.toString() === userId.toString()
                ? friendship.userB
                : friendship.userA,
        );
    }
}
