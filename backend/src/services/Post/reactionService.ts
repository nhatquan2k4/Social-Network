import { ReactionRepository, ReactionType, CreateReactionData } from "../../repositories/Post/reactionRepository";
import { PostRepository } from "../../repositories/Post/postRepository";
import { Types } from "mongoose";
import Post from "../../models/Post/post";

export class ReactionService {
    private reactionRepository: ReactionRepository;
    private postRepository: PostRepository;

    constructor() {
        this.reactionRepository = new ReactionRepository();
        this.postRepository = new PostRepository();
    }

    /**
     * React vào post (hoặc thay đổi reaction type)
     * Logic: 
     * - Nếu chưa react → Tạo mới + tăng counter
     * - Nếu đã react cùng type → Xóa (toggle) + giảm counter
     * - Nếu đã react khác type → Update + điều chỉnh counter
     */
    async reactToPost(userId: Types.ObjectId, postId: string, reactionType: ReactionType) {
        // Kiểm tra post tồn tại
        const postExists = await this.postRepository.exists(postId);
        if (!postExists) {
            throw new Error("Post khong ton tai");
        }

        // Kiểm tra reaction hiện tại
        const existingReaction = await this.reactionRepository.findByUserAndPost(userId, postId);

        if (existingReaction) {
            const oldType = existingReaction.reactionType;

            // Toggle: Nếu react cùng type → Xóa
            if (oldType === reactionType) {
                await this.reactionRepository.deleteByUserAndPost(userId, postId);
                await this.decrementReactionCounter(postId, reactionType);

                return {
                    action: "unreacted",
                    reactionType,
                    message: "Da bo reaction"
                };
            }

            // Đổi reaction type
            await this.reactionRepository.upsert({ userId, postId, reactionType });

            // Cập nhật counters: giảm cũ, tăng mới
            await this.decrementReactionCounter(postId, oldType);
            await this.incrementReactionCounter(postId, reactionType);

            return {
                action: "changed",
                oldType,
                newType: reactionType,
                message: "Da doi reaction"
            };
        }

        // Tạo reaction mới
        await this.reactionRepository.create({ userId, postId, reactionType });
        await this.incrementReactionCounter(postId, reactionType);

        return {
            action: "reacted",
            reactionType,
            message: "Da react thanh cong"
        };
    }

    /**
     * Bỏ react
     */
    async unreactPost(userId: Types.ObjectId, postId: string) {
        const reaction = await this.reactionRepository.findByUserAndPost(userId, postId);

        if (!reaction) {
            throw new Error("Chua react bai dang nay");
        }

        await this.reactionRepository.deleteByUserAndPost(userId, postId);
        await this.decrementReactionCounter(postId, reaction.reactionType);

        return {
            success: true,
            message: "Da bo reaction"
        };
    }

    /**
     * Lấy danh sách reactions của post
     */
    async getReactionsByPost(postId: string, limit = 50, skip = 0) {
        const reactions = await this.reactionRepository.findByPostId(postId, { limit, skip });
        const totalCount = await this.reactionRepository.countByPostId(postId);
        const countByType = await this.reactionRepository.countByPostIdAndType(postId);

        return {
            reactions,
            totalCount,
            countByType,
            pagination: {
                limit,
                skip,
                hasMore: totalCount > skip + reactions.length
            }
        };
    }

    /**
     * Kiểm tra user đã react post chưa
     */
    async getUserReaction(userId: Types.ObjectId, postId: string) {
        return await this.reactionRepository.findByUserAndPost(userId, postId);
    }

    /**
     * Lấy reactions của user (bài user đã react)
     */
    async getUserReactions(userId: Types.ObjectId, limit = 20, skip = 0) {
        return await this.reactionRepository.findByUserId(userId, { limit, skip });
    }

    /**
     * Lấy danh sách users đã react một post (theo type nếu có)
     */
    async getUsersWhoReacted(
        postId: string,
        reactionType?: ReactionType,
        limit = 50,
        skip = 0
    ) {
        return await this.reactionRepository.getUsersByPostId(
            postId,
            reactionType,
            { limit, skip }
        );
    }

    /**
     * Sync reaction counters (dùng khi cần sync lại dữ liệu)
     * Đếm lại từ Reaction collection và update vào Post
     */
    async syncReactionCounters(postId: string) {
        const countByType = await this.reactionRepository.countByPostIdAndType(postId);

        // Chuyển đổi object thành Map
        const reactionsMap = new Map<string, number>();
        Object.keys(countByType).forEach(type => {
            reactionsMap.set(type, countByType[type]);
        });

        // Update trực tiếp vào Post model
        await Post.findByIdAndUpdate(
            postId,
            { reactions: reactionsMap },
            { new: true }
        );

        return {
            success: true,
            counters: countByType
        };
    }

    /**
     * PRIVATE: Tăng counter trong Post (internal use only)
     */
    private async incrementReactionCounter(postId: string, reactionType: string) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { [`reactions.${reactionType}`]: 1 } },
            { new: true }
        );
    }

    /**
     * PRIVATE: Giảm counter trong Post (internal use only)
     */
    private async decrementReactionCounter(postId: string, reactionType: string) {
        return await Post.findByIdAndUpdate(
            postId,
            { $inc: { [`reactions.${reactionType}`]: -1 } },
            { new: true }
        );
    }
}
