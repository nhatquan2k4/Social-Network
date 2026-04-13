import { Types } from "mongoose";
import { FriendModel as Friend } from "../../friends/shared/friends.model";
import { PostRepository } from "../shared/posts.repo";
import { formatPost } from "../shared/posts.util";

export class FeedService {
    private postRepository: PostRepository;

    constructor() {
        this.postRepository = new PostRepository();
    }

    async getFeed(userId: Types.ObjectId, page = 1, limit = 20) {
        const friendships = await Friend.find({
            $or: [{ userA: userId }, { userB: userId }],
        }).select("userA userB");

        const preferredIds = new Set<string>([userId.toString()]);

        friendships.forEach((friendship: any) => {
            const friendId =
                friendship.userA.toString() === userId.toString()
                    ? friendship.userB.toString()
                    : friendship.userA.toString();
            preferredIds.add(friendId);
        });

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
