import { Types } from "mongoose";
import { NotificationService } from "../../notifications/notifications.service.js";
import { PostRepository } from "../shared/posts.repo.js";
import { POST_ERROR_MESSAGES } from "../shared/posts.constants.js";
import {
    buildCommentTree,
    collectDescendantCommentIds,
    formatComment,
} from "../shared/posts.util.js";

export class CommentService {
    private postRepository: PostRepository;
    private notificationService: NotificationService;

    constructor() {
        this.postRepository = new PostRepository();
        this.notificationService = new NotificationService();
    }

    async addComment(
        postId: string,
        authorId: Types.ObjectId,
        content: string,
        parentCommentId?: string,
    ) {
        const normalized = (content || "").trim();
        if (!normalized) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_EMPTY);
        }

        const rawPost = await this.postRepository.findRawById(postId);
        if (!rawPost) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        let parentAuthorId: string | null = null;

        if (parentCommentId) {
            const parentComment = (rawPost.comments || []).find(
                (comment: any) => comment._id.toString() === parentCommentId,
            );

            if (!parentComment) {
                throw new Error(POST_ERROR_MESSAGES.PARENT_COMMENT_NOT_FOUND);
            }

            parentAuthorId = parentComment.authorId.toString();
        }

        const post = await this.postRepository.addComment(postId, authorId, normalized, parentCommentId);
        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const latestComment = (post.comments || [])[post.comments.length - 1];
        if (!latestComment) {
            throw new Error("Khong the tao comment");
        }

        const postAuthorId = rawPost.authorId.toString();
        const actorId = authorId;

        if (postAuthorId !== authorId.toString()) {
            await this.notificationService.createNotification({
                recipientId: new Types.ObjectId(postAuthorId),
                actorId,
                type: "POST_COMMENTED",
                title: "Bài viết của bạn có bình luận mới",
                body: "vừa bình luận vào bài viết của bạn.",
                entityType: "post",
                entityId: postId,
                metadata: {
                    commentId: latestComment._id.toString(),
                },
            });
        }

        if (
            parentCommentId &&
            parentAuthorId &&
            parentAuthorId !== authorId.toString() &&
            parentAuthorId !== postAuthorId
        ) {
            await this.notificationService.createNotification({
                recipientId: new Types.ObjectId(parentAuthorId),
                actorId,
                type: "COMMENT_REPLIED",
                title: "Comment của bạn có phản hồi mới",
                body: "vừa trả lời comment của bạn.",
                entityType: "comment",
                entityId: parentCommentId,
                metadata: {
                    postId,
                    replyCommentId: latestComment._id.toString(),
                },
            });
        }

        return formatComment(latestComment as any);
    }

    async getComments(postId: string) {
        const result = await this.postRepository.getComments(postId);
        if (!result) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const comments = ((result as any).comments || []).map((comment: any) =>
            formatComment(comment),
        );
        const commentTree = buildCommentTree(comments);

        return {
            comments: commentTree,
            flatComments: comments,
            commentsCount: (result as any).commentsCount || comments.length,
        };
    }

    async updateComment(
        postId: string,
        commentId: string,
        requesterId: Types.ObjectId,
        content: string,
    ) {
        const normalized = (content || "").trim();
        if (!normalized) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_EMPTY);
        }

        const post = await this.postRepository.findRawById(postId);
        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const targetComment = (post.comments || []).find(
            (comment: any) => comment._id.toString() === commentId,
        );
        if (!targetComment) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_NOT_FOUND);
        }

        const isCommentOwner = targetComment.authorId.toString() === requesterId.toString();
        if (!isCommentOwner) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_UPDATE_FORBIDDEN);
        }

        targetComment.content = normalized;
        targetComment.updatedAt = new Date();

        await this.postRepository.save(post);

        return formatComment(targetComment as any);
    }

    async deleteComment(postId: string, commentId: string, requesterId: Types.ObjectId) {
        const post = await this.postRepository.findRawById(postId);
        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        const targetComment = (post.comments || []).find(
            (comment: any) => comment._id.toString() === commentId,
        );
        if (!targetComment) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_NOT_FOUND);
        }

        const isCommentOwner = targetComment.authorId.toString() === requesterId.toString();
        const isPostOwner = post.authorId.toString() === requesterId.toString();

        if (!isCommentOwner && !isPostOwner) {
            throw new Error(POST_ERROR_MESSAGES.COMMENT_DELETE_FORBIDDEN);
        }

        const idsToDelete = collectDescendantCommentIds(post.comments || [], commentId);

        const before = (post.comments || []).length;
        post.comments = post.comments.filter(
            (comment: any) => !idsToDelete.has(comment._id.toString()),
        ) as any;
        const removedCount = before - (post.comments || []).length;
        post.commentsCount = Math.max(0, (post.commentsCount || 0) - removedCount);

        await this.postRepository.save(post);
    }
}
