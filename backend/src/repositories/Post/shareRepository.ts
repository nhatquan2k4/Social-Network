import Share from "../../models/Post/share";
import { Types } from "mongoose";

export interface CreateShareData {
    userId: string | Types.ObjectId;
    originalPostId: string | Types.ObjectId;
    sharePostId: string | Types.ObjectId;
    caption?: string;
}

export interface UpdateShareData {
    caption?: string;
}

export interface FindSharesOptions {
    limit?: number;
    skip?: number;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
}

export class ShareRepository {
    /**
     * Tìm share theo ID
     */
    async findById(shareId: string | Types.ObjectId, populate: boolean = false) {
        const query = Share.findById(shareId);
        if (populate) {
            query
                .populate("userId", "username email displayName avatarUrl")
                .populate("originalPostId", "content media userId")
                .populate("sharePostId", "content media userId");
        }
        return await query.exec();
    }

    /**
     * Tìm nhiều shares theo danh sách IDs
     */
    async findByIds(shareIds: (string | Types.ObjectId)[], populate: boolean = false) {
        const query = Share.find({ _id: { $in: shareIds } });
        if (populate) {
            query
                .populate("userId", "username email displayName avatarUrl")
                .populate("originalPostId", "content media userId");
        }
        return await query.exec();
    }

    /**
     * Tạo share mới
     */
    async create(shareData: CreateShareData) {
        const newShare = new Share(shareData);
        return await newShare.save();
    }

    /**
     * Cập nhật share
     */
    async update(
        shareId: string | Types.ObjectId,
        updateData: UpdateShareData
    ) {
        return await Share.findByIdAndUpdate(
            shareId,
            { $set: updateData },
            { new: true, runValidators: true }
        );
    }

    /**
     * Xóa share
     */
    async delete(shareId: string | Types.ObjectId) {
        return await Share.findByIdAndDelete(shareId);
    }

    /**
     * Xóa nhiều shares theo userId
     */
    async deleteByUserId(userId: string | Types.ObjectId) {
        return await Share.deleteMany({ userId });
    }

    /**
     * Xóa nhiều shares theo originalPostId
     */
    async deleteByOriginalPostId(originalPostId: string | Types.ObjectId) {
        return await Share.deleteMany({ originalPostId });
    }

    /**
     * Tìm shares của một user
     */
    async findByUserId(
        userId: string | Types.ObjectId,
        options?: FindSharesOptions
    ) {
        const query = Share.find({ userId });

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
            .populate("originalPostId", "content media userId")
            .populate("sharePostId", "content media userId")
            .exec();
    }

    /**
     * Tìm shares của một post (những người đã share post này)
     */
    async findByOriginalPostId(
        originalPostId: string | Types.ObjectId,
        options?: FindSharesOptions
    ) {
        const query = Share.find({ originalPostId });

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
            .populate("sharePostId", "content media userId")
            .exec();
    }

    /**
     * Tìm tất cả shares với options
     */
    async findAll(options?: FindSharesOptions) {
        const query = Share.find({});

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
            .populate("originalPostId", "content media userId")
            .populate("sharePostId", "content media userId")
            .exec();
    }

    /**
     * Đếm số lượng shares của một post
     */
    async countByOriginalPostId(originalPostId: string | Types.ObjectId) {
        return await Share.countDocuments({ originalPostId });
    }

    /**
     * Đếm số lượng shares của một user
     */
    async countByUserId(userId: string | Types.ObjectId) {
        return await Share.countDocuments({ userId });
    }

    /**
     * Kiểm tra user đã share post chưa
     */
    async hasUserShared(userId: string | Types.ObjectId, originalPostId: string | Types.ObjectId) {
        const count = await Share.countDocuments({ userId, originalPostId });
        return count > 0;
    }

    /**
     * Kiểm tra share có tồn tại không
     */
    async exists(shareId: string | Types.ObjectId) {
        const count = await Share.countDocuments({ _id: shareId });
        return count > 0;
    }
}
