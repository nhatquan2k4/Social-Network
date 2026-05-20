import { Types } from "mongoose";
import { NotificationService } from "../../notifications/notifications.service.js";
import { emitPostEngagement } from "../../../shared/socket/socket.emitter.js";
import { PostRepository } from "../shared/posts.repo.js";
import { POST_ERROR_MESSAGES } from "../shared/posts.constants.js";
import { formatPost } from "../shared/posts.util.js";
import type {
    LikeNotificationService,
    LikePostRepository,
    LikeServiceDependencies,
    LikeServiceInterface,
} from "./like.service.interface.js";

export class LikeService implements LikeServiceInterface {
    private postRepository: LikePostRepository;
    private notificationService: LikeNotificationService;

    constructor(dependencies: LikeServiceDependencies = {}) {
        this.postRepository = dependencies.postRepository ?? new PostRepository();
        this.notificationService =
            dependencies.notificationService ?? new NotificationService();
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
                title: "Bài viết của bạn có lượt thích mới",
                body: "vừa thích bài viết của bạn.",
                entityType: "post",
                entityId: postId,
            });
        }

        if (!hasLikedBefore && isLikedNow) {
            emitPostEngagement({
                postId,
                actorId: userId.toString(),
                eventId: `${postId}:${userId.toString()}:${Date.now()}`,
                type: "like",
                likeDelta: 1,
                commentDelta: 0,
                createdAt: new Date().toISOString(),
            });
        }

        const populated = await this.postRepository.findById(postId);
        return formatPost(populated as any);
    }
}
