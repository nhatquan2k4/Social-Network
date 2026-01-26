import Post from "../../models/Post/post";
import { Types } from "mongoose";

export interface CreatePostData {
    userId: string | Types.ObjectId;
    content: string;
    media?: string[];
    privacy?: "public" | "friends" | "private";
}

export interface UpdatePostData {
    content?: string;
    media?: string[];
    privacy?: "public" | "friends" | "private";
}

export interface FindPostsOptions {
    userId?: string | Types.ObjectId;
    privacy?: "public" | "friends" | "private";
    limit?: number;
    skip?: number;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
}

export interface CountPostFilter {
    userId?: string | Types.ObjectId;
    privacy?: "public" | "friends" | "private";
}

export interface PaginationOptions {
    limit?: number;
    skip?: number;
}

export class PostRepository {
    /**
     * Tìm post theo ID
     */
    async findById(postId: string | Types.ObjectId, populate: boolean = false) {
        const query = Post.findById(postId);
        if (populate) {
            query.populate("userId", "username email displayName avatarUrl");
        }
        return await query.exec();
    }

    /**
     * Tìm nhiều post theo danh sách IDs
     */
    async findByIds(postIds: (string | Types.ObjectId)[], populate: boolean = false) {
        const query = Post.find({ _id: { $in: postIds } });
        if (populate) {
            query.populate("userId", "username email displayName avatarUrl");
        }
        return await query.exec();
    }

    /**
     * Tạo post mới
     */
    async create(postData: CreatePostData) {
        const newPost = new Post(postData);
        return await newPost.save();
    }

    /**
     * Cập nhật post
     */
    async update(
        postId: string | Types.ObjectId,
        updateData: UpdatePostData
    ) {
        return await Post.findByIdAndUpdate(
            postId,
            { $set: updateData },
            { new: true, runValidators: true }
        );
    }

    /**
     * Xóa post
     */
    async delete(postId: string | Types.ObjectId) {
        return await Post.findByIdAndDelete(postId);
    }

    /**
     * Xóa nhiều post theo userId
     */
    async deleteByUserId(userId: string | Types.ObjectId) {
        return await Post.deleteMany({ userId });
    }

    /**
     * Tìm posts theo userId với các filter options
     */
    async findByUserId(
        userId: string | Types.ObjectId,
        options?: Omit<FindPostsOptions, "userId">,
        populate: boolean = false
    ) {
        const query: any = { userId };

        if (options?.privacy) {
            query.privacy = options.privacy;
        }

        const postQuery = Post.find(query);

        // Populate
        if (populate) {
            postQuery.populate("userId", "username email displayName avatarUrl");
        }

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        postQuery.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            postQuery.skip(options.skip);
        }
        if (options?.limit) {
            postQuery.limit(options.limit);
        }

        return await postQuery.exec();
    }

    /**
     * Tìm tất cả posts với filter options
     */
    async findAll(options?: FindPostsOptions, populate: boolean = false) {
        const query: any = {};

        if (options?.userId) {
            query.userId = options.userId;
        }
        if (options?.privacy) {
            query.privacy = options.privacy;
        }

        const postQuery = Post.find(query);

        // Populate
        if (populate) {
            postQuery.populate("userId", "username email displayName avatarUrl");
        }

        // Sorting
        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        postQuery.sort({ [sortBy]: sortOrder });

        // Pagination
        if (options?.skip) {
            postQuery.skip(options.skip);
        }
        if (options?.limit) {
            postQuery.limit(options.limit);
        }

        return await postQuery.exec();
    }

    /**
     * Đếm số lượng posts
     */
    async count(filter?: Partial<CountPostFilter>) {
        return await Post.countDocuments(filter || {});
    }

    /**
     * Tăng/giảm số lượng comments (CHỈ GỌI TỪ CommentService)
     */
    async incrementCommentsCount(
        postId: string | Types.ObjectId,
        incrementBy: number = 1
    ) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { commentsCount: incrementBy } },
            { new: true }
        );
    }

    /**
     * Tăng/giảm số lượng shares
     */
    async incrementSharesCount(
        postId: string | Types.ObjectId,
        incrementBy: number = 1
    ) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { sharesCount: incrementBy } },
            { new: true }
        );
    }

    /**
     * Tìm posts public (cho newsfeed)
     */
    async findPublicPosts(limit: number = 20, skip: number = 0) {
        return await Post.find({ privacy: "public" })
            .populate("userId", "username email displayName avatarUrl")
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .exec();
    }

    /**
     * Tìm posts của bạn bè (public và friends)
     */
    async findFriendsPosts(
        friendIds: (string | Types.ObjectId)[],
        limit: number = 20,
        skip: number = 0
    ) {
        return await Post.find({
            userId: { $in: friendIds },
            privacy: { $in: ["public", "friends"] }
        })
            .populate("userId", "username email displayName avatarUrl")
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .exec();
    }

    /**
     * Tìm posts cho newsfeed (bao gồm posts của bạn bè và public posts)
     */
    async findNewsfeedPosts(
        userId: string | Types.ObjectId,
        friendIds: (string | Types.ObjectId)[],
        limit: number = 20,
        skip: number = 0
    ) {
        return await Post.find({
            $or: [
                { userId: userId },
                { userId: { $in: friendIds }, privacy: { $in: ["public", "friends"] } },
                { privacy: "public", userId: { $ne: userId } }
            ]
        })
            .populate("userId", "username email displayName avatarUrl")
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .exec();
    }

    /**
     * Kiểm tra post có tồn tại không
     */
    async exists(postId: string | Types.ObjectId) {
        const post = await Post.findById(postId).select("_id").lean();
        return !!post;
    }

    /**
     * Kiểm tra user có phải chủ post không
     */
    async isOwner(postId: string | Types.ObjectId, userId: string | Types.ObjectId) {
        const post = await Post.findById(postId).select("userId").lean();
        return post?.userId.toString() === userId.toString();
    }

    /**
     * Tìm posts theo khoảng thời gian
     */
    async findByDateRange(
        startDate: Date,
        endDate: Date,
        options?: FindPostsOptions
    ) {
        const query: any = {
            createdAt: {
                $gte: startDate,
                $lte: endDate
            }
        };

        if (options?.userId) {
            query.userId = options.userId;
        }
        if (options?.privacy) {
            query.privacy = options.privacy;
        }

        const postQuery = Post.find(query);

        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        postQuery.sort({ [sortBy]: sortOrder });

        if (options?.skip) {
            postQuery.skip(options.skip);
        }
        if (options?.limit) {
            postQuery.limit(options.limit);
        }

        return await postQuery.exec();
    }

    /**
     * Tìm posts có chứa media
     */
    async findPostsWithMedia(
        userId?: string | Types.ObjectId,
        limit: number = 20,
        skip: number = 0
    ) {
        const query: any = {
            media: { $exists: true, $ne: [] }
        };

        if (userId) {
            query.userId = userId;
        }

        return await Post.find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .exec();
    }

    /**
     * Tìm kiếm posts theo nội dung
     */
    async searchByContent(
        searchTerm: string,
        options?: FindPostsOptions
    ) {
        const query: any = {
            content: { $regex: searchTerm, $options: "i" }
        };

        if (options?.userId) {
            query.userId = options.userId;
        }
        if (options?.privacy) {
            query.privacy = options.privacy;
        }

        const postQuery = Post.find(query);

        const sortBy = options?.sortBy || "createdAt";
        const sortOrder = options?.sortOrder === "asc" ? 1 : -1;
        postQuery.sort({ [sortBy]: sortOrder });

        if (options?.skip) {
            postQuery.skip(options.skip);
        }
        if (options?.limit) {
            postQuery.limit(options.limit);
        }

        return await postQuery.exec();
    }
}