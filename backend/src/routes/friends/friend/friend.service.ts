import { Types } from "mongoose";
import { FriendRepository } from "../shared/friends.repo.js";
import type {
    FriendServiceDependencies,
    FriendServiceInterface,
    FriendServiceRepository,
} from "./friend.service.interface.js";

export class FriendService implements FriendServiceInterface {
    private friendRepository: FriendServiceRepository;

    constructor(dependencies: FriendServiceDependencies = {}) {
        this.friendRepository = dependencies.friendRepository ?? new FriendRepository();
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
