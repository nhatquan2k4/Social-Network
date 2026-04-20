import { Types } from "mongoose";
import { NotificationService } from "../../notifications/notifications.service.js";
import { PostRepository } from "../shared/posts.repo.js";
import { POST_ERROR_MESSAGES } from "../shared/posts.constants.js";
import { formatPost } from "../shared/posts.util.js";

export class LikeService {
    private postRepository: PostRepository;
    private notificationService: NotificationService;

    constructor() {
        this.postRepository = new PostRepository();
        this.notificationService = new NotificationService();
    }

    async toggleLike(postId: string, userId: Types.ObjectId) {
        const rawPost = await this.postRepository.findRawById(postId);
        if (!rawPost) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const hasLikedBefore = (rawPost.likes || []).some(
            (id: Types.ObjectId) => id.toString() === userId.toString(),
        );

        const post = await this.postRepository.toggleLike(postId, userId);

        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const isLikedNow = post.likes.some(
            (id: Types.ObjectId) => id.toString() === userId.toString(),
        );
        const postAuthorId = rawPost.authorId.toString();

        if (!hasLikedBefore && isLikedNow && postAuthorId !== userId.toString()) {
            await this.notificationService.createNotification({
                recipientId: new Types.ObjectId(postAuthorId),
                actorId: userId,
                type: "POST_LIKED",
                title: "Bai viet cua ban co luot thich moi",
                body: "Co nguoi vua thich bai viet cua ban.",
                entityType: "post",
                entityId: postId,
            });
        }

        const populated = await this.postRepository.findById(postId);
        return formatPost(populated as any);
    }
}
