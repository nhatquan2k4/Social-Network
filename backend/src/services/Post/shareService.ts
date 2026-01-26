import { ShareRepository, CreateShareData, UpdateShareData, FindSharesOptions } from "../../repositories/Post/shareRepository";
import { PostRepository } from "../../repositories/Post/postRepository";
import { Types } from "mongoose";
import Post from "../../models/Post/post";

export class ShareService {
    private shareRepository: ShareRepository;
    private postRepository: PostRepository;

    constructor() {
        this.shareRepository = new ShareRepository();
        this.postRepository = new PostRepository();
    }

    /**
     * Share một post
     * Tạo một post mới chứa post được share và tạo record trong Share collection
     */
    async sharePost(userId: Types.ObjectId, originalPostId: string, caption?: string) {
        // Kiểm tra post gốc tồn tại
        const originalPost = await this.postRepository.findById(originalPostId);
        if (!originalPost) {
            throw new Error("Post khong ton tai");
        }

        // Kiểm tra user đã share post này chưa
        const hasShared = await this.shareRepository.hasUserShared(userId, originalPostId);
        if (hasShared) {
            throw new Error("Ban da share bai viet nay roi");
        }

        // Tạo post mới chứa nội dung share
        const sharePost = await this.postRepository.create({
            userId,
            content: caption || `Shared a post from ${originalPost.userId}`,
            privacy: "public"
        });

        // Tạo record share
        const share = await this.shareRepository.create({
            userId,
            originalPostId,
            sharePostId: sharePost._id,
            caption: caption || ""
        });

        // Tăng share counter trong post gốc
        await this.incrementPostShareCounter(originalPostId);

        return {
            share,
            sharePost,
            originalPost
        };
    }

    /**
     * Lấy share theo ID
     */
    async getShareById(shareId: string | Types.ObjectId, populate: boolean = false) {
        const share = await this.shareRepository.findById(shareId, populate);
        if (!share) {
            throw new Error("Share khong ton tai");
        }
        return share;
    }

    /**
     * Cập nhật caption của share
     */
    async updateShare(shareId: string | Types.ObjectId, updateData: UpdateShareData) {
        const updatedShare = await this.shareRepository.update(shareId, updateData);
        if (!updatedShare) {
            throw new Error("Share khong ton tai");
        }
        return updatedShare;
    }

    /**
     * Xóa share (bỏ share)
     * Xóa share record và post đã tạo khi share
     */
    async deleteShare(shareId: string | Types.ObjectId) {
        const share = await this.shareRepository.findById(shareId);
        if (!share) {
            throw new Error("Share khong ton tai");
        }

        // Xóa post đã tạo khi share
        await this.postRepository.delete(share.sharePostId);

        // Xóa share record
        const deleted = await this.shareRepository.delete(shareId);

        // Giảm share counter trong post gốc
        await this.decrementPostShareCounter(share.originalPostId);

        return deleted;
    }

    /**
     * Lấy danh sách shares của một post
     */
    async getSharesByPost(
        originalPostId: string | Types.ObjectId,
        options?: FindSharesOptions
    ) {
        const shares = await this.shareRepository.findByOriginalPostId(originalPostId, options);
        const totalCount = await this.shareRepository.countByOriginalPostId(originalPostId);

        return {
            shares,
            totalCount,
            pagination: {
                limit: options?.limit || 20,
                skip: options?.skip || 0,
                hasMore: totalCount > (options?.skip || 0) + shares.length
            }
        };
    }

    /**
     * Lấy danh sách shares của user
     */
    async getSharesByUserId(
        userId: string | Types.ObjectId,
        options?: FindSharesOptions
    ) {
        const shares = await this.shareRepository.findByUserId(userId, options);
        const totalCount = await this.shareRepository.countByUserId(userId);

        return {
            shares,
            totalCount,
            pagination: {
                limit: options?.limit || 20,
                skip: options?.skip || 0,
                hasMore: totalCount > (options?.skip || 0) + shares.length
            }
        };
    }

    /**
     * Kiểm tra user đã share post chưa
     */
    async hasUserShared(userId: Types.ObjectId, originalPostId: string) {
        const hasShared = await this.shareRepository.hasUserShared(userId, originalPostId);
        return {
            hasShared
        };
    }

    /**
     * Xóa tất cả shares của một post
     */
    async deleteSharesByPostId(originalPostId: string | Types.ObjectId) {
        // Lấy tất cả shares của post
        const shares = await this.shareRepository.findByOriginalPostId(originalPostId);

        // Xóa tất cả share posts
        for (const share of shares) {
            await this.postRepository.delete(share.sharePostId);
        }

        // Xóa tất cả share records
        return await this.shareRepository.deleteByOriginalPostId(originalPostId);
    }

    /**
     * PRIVATE: Tăng share counter trong Post
     */
    private async incrementPostShareCounter(postId: string | Types.ObjectId) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { sharesCount: 1 } },
            { new: true }
        );
    }

    /**
     * PRIVATE: Giảm share counter trong Post
     */
    private async decrementPostShareCounter(postId: string | Types.ObjectId) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { sharesCount: -1 } },
            { new: true }
        );
    }

    /**
     * Sync share counters (dùng khi cần sync lại dữ liệu)
     */
    async syncShareCounters(postId: string) {
        const count = await this.shareRepository.countByOriginalPostId(postId);

        await Post.findByIdAndUpdate(
            postId,
            { sharesCount: count },
            { new: true }
        );

        return {
            success: true,
            count
        };
    }
}
