import { Types } from "mongoose";
import { FriendRepository } from "../../friends/shared/friends.repo.js";
import { PostRepository } from "../shared/posts.repo.js";
import { formatPost } from "../shared/posts.util.js";
import type {
    FeedFriendRepository,
    FeedPostRepository,
    FeedServiceDependencies,
    FeedServiceInterface,
} from "./feed.service.interface.js";

export class FeedService implements FeedServiceInterface {
    private friendRepository: FeedFriendRepository;
    private postRepository: FeedPostRepository;

    constructor(dependencies: FeedServiceDependencies = {}) {
        this.friendRepository = dependencies.friendRepository ?? new FriendRepository();
        this.postRepository = dependencies.postRepository ?? new PostRepository();
    }

    async getFeed(userId: Types.ObjectId, page = 1, limit = 20) {
        const preferredIds = new Set<string>([userId.toString()]);
        const friendIds = await this.friendRepository.getFriendIds(userId);
        friendIds.forEach((friendId) => preferredIds.add(friendId));

        const preferredAuthorIds = Array.from(preferredIds).map((id) => new Types.ObjectId(id));
        const safeLimit = Math.max(1, Math.min(limit, 50));
        const safePage = Math.max(1, page);
        const skip = (safePage - 1) * safeLimit;

        const [items, total] = await Promise.all([
            this.postRepository.findFeed(preferredAuthorIds, skip, safeLimit),
            this.postRepository.countAll(),
        ]);

        return {
            items: items.map((item: any) => formatPost(item as any)),
            page: safePage,
            limit: safeLimit,
            total,
            hasMore: skip + items.length < total,
        };
    }
}
