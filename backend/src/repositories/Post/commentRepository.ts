import Comment from "../../models/Post/comment";
import { Types } from "mongoose";

export interface CreateCommentData {
    postId: string | Types.ObjectId;
    userId: string | Types.ObjectId;
    content: string;
    parentCommentId?: string | Types.ObjectId | null;
}

export interface UpdateCommentData {
    content?: string;
}

export interface FindCommentsOptions {
    limit?: number;
    skip?: number;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
}

export class CommentRepository {
    /**
     * Tìm comment theo ID
     */
    async findById(commentId: string | Types.ObjectId, populate: boolean = false) {
        const query = Comment.findById(commentId);
        if (populate) {
            query
                .populate("userId", "username email displayName avatarUrl")
                .populate("postId", "content")
                .populate("parentCommentId", "content userId");
        }
        return await query.exec();
    }

    /**
     * Tìm nhiều comments theo danh sách IDs
     */
    async findByIds(commentIds: (string | Types.ObjectId)[], populate: boolean = false) {
        const query = Comment.find({ _id: { $in: commentIds } });
        if (populate) {
            query.populate("userId", "username email displayName avatarUrl");
        }
        return await query.exec();
    }

    /**
     * Tạo comment mới
     */
    async create(commentData: CreateCommentData) {
        const newComment = new Comment(commentData);
        return await newComment.save();
    }

    /**
     * Cập nhật comment
     */
    async update(
        commentId: string | Types.ObjectId,
        updateData: UpdateCommentData
    ) {
        return await Comment.findByIdAndUpdate(
            commentId,
            { $set: updateData },
            { new: true, runValidators: true }
        );
    }

    /**
     * Xóa comment
     */
    async delete(commentId: string | Types.ObjectId) {
        return await Comment.findByIdAndDelete(commentId);
    }

    /**
     * Xóa nhiều comments theo postId
     */
    async deleteByPostId(postId: string | Types.ObjectId) {
        return await Comment.deleteMany({ postId });
    }

    /**
     * Xóa nhiều comments theo userId
     */
    async deleteByUserId(userId: string | Types.ObjectId) {
        return await Comment.deleteMany({ userId });
    }

    /**
     * Xóa nhiều comments theo parentCommentId (xóa replies)
     */
    async deleteReplies(parentCommentId: string | Types.ObjectId) {
        return await Comment.deleteMany({ parentCommentId });
    }

    /**
     * Tìm comments của một post
     */
    async findByPostId(
        postId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        const query = Comment.find({
            postId,
            parentCommentId: null // Chỉ lấy comment gốc, không lấy replies
        });

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        query.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            query.skip(options.skip);
        }
        if (options?.limit) {
            query.limit(options.limit);
        }

        return await query
            .populate("userId", "username email displayName avatarUrl")
            .exec();
    }

    /**
     * Tìm replies của một comment
     */
    async findReplies(
        parentCommentId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        const query = Comment.find({ parentCommentId });

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        query.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            query.skip(options.skip);
        }
        if (options?.limit) {
            query.limit(options.limit);
        }

        return await query
            .populate("userId", "username email displayName avatarUrl")
            .exec();
    }

    /**
     * Tìm comments của một user
     */
    async findByUserId(
        userId: string | Types.ObjectId,
        options?: FindCommentsOptions
    ) {
        const query = Comment.find({ userId });

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        query.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            query.skip(options.skip);
        }
        if (options?.limit) {
            query.limit(options.limit);
        }

        return await query
            .populate("postId", "content")
            .exec();
    }

    /**
     * Đếm số lượng comments của một post
     */
    async countByPostId(postId: string | Types.ObjectId) {
        return await Comment.countDocuments({
            postId,
            parentCommentId: null // Chỉ đếm comment gốc
        });
    }

    /**
     * Đếm số lượng replies của một comment
     */
    async countReplies(parentCommentId: string | Types.ObjectId) {
        return await Comment.countDocuments({ parentCommentId });
    }

    /**
     * Đếm tổng số comments (bao gồm cả replies)
     */
    async countAllByPostId(postId: string | Types.ObjectId) {
        return await Comment.countDocuments({ postId });
    }

    /**
     * Kiểm tra comment có tồn tại không
     */
    async exists(commentId: string | Types.ObjectId) {
        const count = await Comment.countDocuments({ _id: commentId });
        return count > 0;
    }

    /**
     * React vào comment (tăng counter)
     */
    async incrementReaction(commentId: string | Types.ObjectId, reactionType: string) {
        return await Comment.findByIdAndUpdate(
            commentId,
            { $inc: { [`reactions.${reactionType}`]: 1 } },
            { new: true }
        );
    }

    /**
     * Giảm reaction counter
     */
    async decrementReaction(commentId: string | Types.ObjectId, reactionType: string) {
        return await Comment.findByIdAndUpdate(
            commentId,
            { $inc: { [`reactions.${reactionType}`]: -1 } },
            { new: true }
        );
    }
}
