import { Request, Response } from 'express';
import { ReactionService } from '../../services/Post/reactionService';
import { ReactionType } from '../../repositories/Post/reactionRepository';
import { Types } from 'mongoose';

const reactionService = new ReactionService();

/**
 * React vào bài viết (hoặc thay đổi/bỏ reaction)
 */
export const reactToPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const { reactionType } = req.body;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        if (!reactionType) {
            return res.status(400).json({ message: 'Vui long chon loai reaction' });
        }

        const validReactionTypes: ReactionType[] = ['like', 'love', 'haha', 'wow', 'sad', 'angry'];
        if (!validReactionTypes.includes(reactionType)) {
            return res.status(400).json({ message: 'Loai reaction khong hop le' });
        }

        const result = await reactionService.reactToPost(userId, postId, reactionType);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi react bai viet:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Bỏ react bài viết
 */
export const unreactPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const result = await reactionService.unreactPost(userId, postId);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi bo react bai viet:', error);
        if (error.message === 'Chua react bai dang nay') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách reactions của bài viết
 */
export const getReactionsByPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const { limit, skip } = req.query;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const limitNum = limit ? parseInt(limit as string) : 50;
        const skipNum = skip ? parseInt(skip as string) : 0;

        const result = await reactionService.getReactionsByPost(postId, limitNum, skipNum);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi lay danh sach reactions:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Kiểm tra reaction của user hiện tại cho bài viết
 */
export const getReactionByUserAndPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const reaction = await reactionService.getUserReaction(userId, postId);

        return res.status(200).json({
            hasReacted: !!reaction,
            reaction: reaction || null
        });
    } catch (error: any) {
        console.error('Loi khi kiem tra reaction:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
