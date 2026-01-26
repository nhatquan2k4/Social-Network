import { CommentRepository, CreateCommentData, UpdateCommentData, FindCommentsOptions } from "../../repositories/Post/commentRepository";
import { PostRepository } from "../../repositories/Post/postRepository";
import { Types } from "mongoose";
import Post from "../../models/Post/post";

export class CommentService {
    private commentRepository: CommentRepository;
    private postRepository: PostRepository;

    constructor() {
        this.commentRepository = new CommentRepository();
        this.postRepository = new PostRepository();
    }

    /**
     * Tạo comment mới
     */
    async createComment(commentData: CreateCommentData) {
        // Kiểm tra post tồn tại
        const postExists = await this.postRepository.exists(commentData.postId as string);
        if (!postExists) {
            throw new Error("Post khong ton tai");
        }

        // Nếu là reply, kiểm tra parent comment tồn tại
        if (commentData.parentCommentId) {
            const parentExists = await this.commentRepository.exists(commentData.parentCommentId);
            if (!parentExists) {
                throw new Error("Comment goc khong ton tai");
            }
        }

        const newComment = await this.commentRepository.create(commentData);

        // Tăng comment counter trong Post (chỉ khi là comment gốc)
        if (!commentData.parentCommentId) {
            await this.incrementPostCommentCounter(commentData.postId as string);
        }

        return newComment;
    }

    /**
     * Lấy comment theo ID
     */
    async getCommentById(commentId: string | Types.ObjectId, populate: boolean = false) {
        const comment = await this.commentRepository.findById(commentId, populate);
        if (!comment) {
            throw new Error("Comment khong ton tai");
        }
        return comment;
    }

    /**
     * Cập nhật comment
     */
    async updateComment(commentId: string | Types.ObjectId, updateData: UpdateCommentData) {
        const updatedComment = await this.commentRepository.update(commentId, updateData);
        if (!updatedComment) {
            throw new Error("Comment khong ton tai");
        }
        return updatedComment;
    }

    /**
     * Xóa comment
     */
    async deleteComment(commentId: string | Types.ObjectId) {
        const comment = await this.commentRepository.findById(commentId);
        if (!comment) {
            throw new Error("Comment khong ton tai");
        }

        // Xóa tất cả replies của comment này
        await this.commentRepository.deleteReplies(commentId);

        // Xóa comment
        const deleted = await this.commentRepository.delete(commentId);

        // Giảm comment counter trong Post (chỉ khi là comment gốc)
        if (!comment.parentCommentId) {
            await this.decrementPostCommentCounter(comment.postId);
        }

        return deleted;
    }

    /**
     * Lấy danh sách comments của một post
     */
    async getCommentsByPostId(
        postId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        const comments = await this.commentRepository.findByPostId(postId, options);
        const totalCount = await this.commentRepository.countByPostId(postId);

        return {
            comments,
            totalCount,
            pagination: {
                limit: options?.limit || 20,
                skip: options?.skip || 0,
                hasMore: totalCount > (options?.skip || 0) + comments.length
            }
        };
    }

    /**
     * Lấy danh sách replies của một comment
     */
    async getReplies(
        parentCommentId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        const replies = await this.commentRepository.findReplies(parentCommentId, options);
        const totalCount = await this.commentRepository.countReplies(parentCommentId);

        return {
            replies,
            totalCount,
            pagination: {
                limit: options?.limit || 10,
                skip: options?.skip || 0,
                hasMore: totalCount > (options?.skip || 0) + replies.length
            }
        };
    }

    /**
     * Lấy comments của user
     */
    async getCommentsByUserId(
        userId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        return await this.commentRepository.findByUserId(userId, options);
    }

    /**
     * Xóa tất cả comments của một post
     */
    async deleteCommentsByPostId(postId: string | Types.ObjectId) {
        return await this.commentRepository.deleteByPostId(postId);
    }

    /**
     * PRIVATE: Tăng comment counter trong Post
     */
    private async incrementPostCommentCounter(postId: string) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { commentsCount: 1 } },
            { new: true }
        );
    }

    /**
     * PRIVATE: Giảm comment counter trong Post
     */
    private async decrementPostCommentCounter(postId: string | Types.ObjectId) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { commentsCount: -1 } },
            { new: true }
        );
    }

    /**
     * Sync comment counters (dùng khi cần sync lại dữ liệu)
     */
    async syncCommentCounters(postId: string) {
        const count = await this.commentRepository.countByPostId(postId);

        await Post.findByIdAndUpdate(
            postId,
            { commentsCount: count },
            { new: true }
        );

        return {
            success: true,
            count
        };
    }
}
