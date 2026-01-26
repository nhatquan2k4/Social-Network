import Reaction from "../../models/Post/reaction";
import { Types } from "mongoose";

export type ReactionType = "like" | "love" | "haha" | "wow" | "sad" | "angry";

export interface CreateReactionData {
    postId: string | Types.ObjectId;
    userId: string | Types.ObjectId;
    reactionType: ReactionType;
}

export interface FindReactionsOptions {
    limit?: number;
    skip?: number;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
}

export class ReactionRepository {
    /**
     * Tìm reaction theo ID
     */
    async findById(reactionId: string | Types.ObjectId, populate: boolean = false) {
        const query = Reaction.findById(reactionId);
        if (populate) {
            query.populate("userId", "username email").populate("postId", "content");
        }
        return await query.exec();
    }

    /**
     * Tìm reaction của user cho một post
     */
    async findByUserAndPost(
        userId: string | Types.ObjectId,
        postId: string | Types.ObjectId
    ) {
        return await Reaction.findOne({ userId, postId }).exec();
    }

    /**
     * Tìm tất cả reactions của một post
     */
    async findByPostId(
        postId: string | Types.ObjectId,
        options?: FindReactionsOptions
    ) {
        const query = Reaction.find({ postId });

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

        return await query.populate("userId", "username email").exec();
    }

    /**
     * Tìm tất cả reactions của một user
     */
    async findByUserId(
        userId: string | Types.ObjectId,
        options?: FindReactionsOptions
    ) {
        const query = Reaction.find({ userId });

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

        return await query.populate("postId", "content").exec();
    }

    /**
     * Tạo hoặc cập nhật reaction (upsert)
     * Nếu user đã react post thì update, chưa thì tạo mới
     */
    async upsert(reactionData: CreateReactionData) {
        return await Reaction.findOneAndUpdate(
            {
                postId: reactionData.postId,
                userId: reactionData.userId
            },
            {
                $set: { reactionType: reactionData.reactionType }
            },
            {
                upsert: true,
                new: true,
                runValidators: true
            }
        ).exec();
    }

    /**
     * Tạo reaction mới
     */
    async create(reactionData: CreateReactionData) {
        const newReaction = new Reaction(reactionData);
        return await newReaction.save();
    }

    /**
     * Cập nhật reaction type
     */
    async updateReactionType(
        reactionId: string | Types.ObjectId,
        reactionType: ReactionType
    ) {
        return await Reaction.findByIdAndUpdate(
            reactionId,
            { $set: { reactionType } },
            { new: true, runValidators: true }
        ).exec();
    }

    /**
     * Xóa reaction theo ID
     */
    async delete(reactionId: string | Types.ObjectId) {
        return await Reaction.findByIdAndDelete(reactionId).exec();
    }

    /**
     * Xóa reaction của user cho một post
     */
    async deleteByUserAndPost(
        userId: string | Types.ObjectId,
        postId: string | Types.ObjectId
    ) {
        return await Reaction.findOneAndDelete({ userId, postId }).exec();
    }

    /**
     * Xóa tất cả reactions của một post
     */
    async deleteByPostId(postId: string | Types.ObjectId) {
        return await Reaction.deleteMany({ postId }).exec();
    }

    /**
     * Xóa tất cả reactions của một user
     */
    async deleteByUserId(userId: string | Types.ObjectId) {
        return await Reaction.deleteMany({ userId }).exec();
    }

    /**
     * Đếm tổng số reactions của một post
     */
    async countByPostId(postId: string | Types.ObjectId) {
        return await Reaction.countDocuments({ postId }).exec();
    }

    /**
     * Đếm số lượng reactions theo từng type cho một post
     */
    async countByPostIdAndType(postId: string | Types.ObjectId) {
        const results = await Reaction.aggregate([
            { $match: { postId: new Types.ObjectId(postId.toString()) } },
            {
                $group: {
                    _id: "$reactionType",
                    count: { $sum: 1 }
                }
            }
        ]).exec();

        // Convert array to object
        const reactionCounts: Record<string, number> = {};
        results.forEach((result) => {
            reactionCounts[result._id] = result.count;
        });

        return reactionCounts;
    }

    /**
     * Đếm số lượng reactions theo type cho nhiều posts
     */
    async countByPostIds(postIds: (string | Types.ObjectId)[]) {
        const objectIds = postIds.map(id => new Types.ObjectId(id.toString()));

        const results = await Reaction.aggregate([
            { $match: { postId: { $in: objectIds } } },
            {
                $group: {
                    _id: {
                        postId: "$postId",
                        reactionType: "$reactionType"
                    },
                    count: { $sum: 1 }
                }
            }
        ]).exec();

        // Convert to nested object: { postId: { reactionType: count } }
        const reactionsByPost: Record<string, Record<string, number>> = {};
        results.forEach((result) => {
            const postId = result._id.postId.toString();
            const reactionType = result._id.reactionType;

            if (!reactionsByPost[postId]) {
                reactionsByPost[postId] = {};
            }
            reactionsByPost[postId][reactionType] = result.count;
        });

        return reactionsByPost;
    }

    /**
     * Lấy danh sách users đã react một post (theo type nếu có)
     */
    async getUsersByPostId(
        postId: string | Types.ObjectId,
        reactionType?: ReactionType,
        options?: FindReactionsOptions
    ) {
        const query: any = { postId };
        if (reactionType) {
            query.reactionType = reactionType;
        }

        const reactionsQuery = Reaction.find(query);

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        reactionsQuery.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            reactionsQuery.skip(options.skip);
        }
        if (options?.limit) {
            reactionsQuery.limit(options.limit);
        }

        return await reactionsQuery
            .populate("userId", "username email")
            .select("userId reactionType createdAt")
            .exec();
    }

    /**
     * Kiểm tra user đã react post chưa
     */
    async hasUserReacted(
        userId: string | Types.ObjectId,
        postId: string | Types.ObjectId
    ) {
        const reaction = await Reaction.findOne({ userId, postId })
            .select("_id")
            .lean()
            .exec();
        return !!reaction;
    }

    /**
     * Lấy reaction type của user cho một post
     */
    async getUserReactionType(
        userId: string | Types.ObjectId,
        postId: string | Types.ObjectId
    ): Promise<ReactionType | null> {
        const reaction = await Reaction.findOne({ userId, postId })
            .select("reactionType")
            .lean()
            .exec();
        return reaction ? reaction.reactionType : null;
    }

    /**
     * Lấy reactions của user cho nhiều posts
     */
    async getUserReactionsForPosts(
        userId: string | Types.ObjectId,
        postIds: (string | Types.ObjectId)[]
    ) {
        const reactions = await Reaction.find({
            userId,
            postId: { $in: postIds }
        })
            .select("postId reactionType")
            .lean()
            .exec();

        // Convert to object: { postId: reactionType }
        const reactionsByPost: Record<string, ReactionType> = {};
        reactions.forEach((reaction) => {
            reactionsByPost[reaction.postId.toString()] = reaction.reactionType;
        });

        return reactionsByPost;
    }

    /**
     * Lấy top reactions cho một post
     */
    async getTopReactionTypes(postId: string | Types.ObjectId, limit: number = 3) {
        const results = await Reaction.aggregate([
            { $match: { postId: new Types.ObjectId(postId.toString()) } },
            {
                $group: {
                    _id: "$reactionType",
                    count: { $sum: 1 }
                }
            },
            { $sort: { count: -1 } },
            { $limit: limit }
        ]).exec();

        return results.map(result => ({
            reactionType: result._id,
            count: result.count
        }));
    }

    /**
     * Kiểm tra reaction có tồn tại không
     */
    async exists(reactionId: string | Types.ObjectId) {
        const reaction = await Reaction.findById(reactionId)
            .select("_id")
            .lean()
            .exec();
        return !!reaction;
    }

    /**
     * Kiểm tra user có phải chủ reaction không
     */
    async isOwner(
        reactionId: string | Types.ObjectId,
        userId: string | Types.ObjectId
    ) {
        const reaction = await Reaction.findById(reactionId)
            .select("userId")
            .lean()
            .exec();
        return reaction?.userId.toString() === userId.toString();
    }

    /**
     * Lấy thống kê reactions của user
     */
    async getUserReactionStats(userId: string | Types.ObjectId) {
        const stats = await Reaction.aggregate([
            { $match: { userId: new Types.ObjectId(userId.toString()) } },
            {
                $group: {
                    _id: "$reactionType",
                    count: { $sum: 1 }
                }
            }
        ]).exec();

        const total = stats.reduce((sum, stat) => sum + stat.count, 0);

        return {
            total,
            byType: stats.reduce((acc, stat) => {
                acc[stat._id] = stat.count;
                return acc;
            }, {} as Record<string, number>)
        };
    }

    /**
     * Tìm reactions mới nhất
     */
    async findRecent(limit: number = 10, skip: number = 0) {
        return await Reaction.find()
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .populate("userId", "username email")
            .populate("postId", "content")
            .exec();
    }

    /**
     * Đổi reaction type (từ type này sang type khác)
     */
    async changeReactionType(
        userId: string | Types.ObjectId,
        postId: string | Types.ObjectId,
        newReactionType: ReactionType
    ) {
        return await Reaction.findOneAndUpdate(
            { userId, postId },
            { $set: { reactionType: newReactionType } },
            { new: true, runValidators: true }
        ).exec();
    }
}
