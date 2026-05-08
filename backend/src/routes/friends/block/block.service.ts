import { Types } from "mongoose";
import { UserRepository } from "../../users/shared/users.repo.js";
import { BlockRepository } from "../shared/friends.repo.js";
import {
    FriendSelfBlockError,
    FriendUserNotFoundError,
    MissingBlockUserError,
} from "../shared/friends.errors.js";

export class BlockService {
    private blockRepository: BlockRepository;
    private userRepository: UserRepository;

    constructor() {
        this.blockRepository = new BlockRepository();
        this.userRepository = new UserRepository();
    }

    async blockUser(blockerId: Types.ObjectId, targetUserId?: string) {
        const normalizedTargetId = String(targetUserId || "").trim();
        if (!normalizedTargetId) {
            throw new MissingBlockUserError();
        }

        if (blockerId.toString() === normalizedTargetId) {
            throw new FriendSelfBlockError();
        }

        const userExists = await this.userRepository.exists(normalizedTargetId);
        if (!userExists) {
            throw new FriendUserNotFoundError();
        }

        const existing = await this.blockRepository.findByUsers(
            blockerId,
            normalizedTargetId,
        );
        if (existing) {
            return existing;
        }

        return await this.blockRepository.create(
            blockerId,
            new Types.ObjectId(normalizedTargetId),
        );
    }

    async unblockUser(blockerId: Types.ObjectId, targetUserId: string) {
        const normalizedTargetId = String(targetUserId || "").trim();
        if (!normalizedTargetId) {
            throw new MissingBlockUserError();
        }

        return await this.blockRepository.deleteByUsers(blockerId, normalizedTargetId);
    }

    async getBlockedUsers(blockerId: Types.ObjectId) {
        return await this.blockRepository.findBlockedByUserId(blockerId);
    }
}

