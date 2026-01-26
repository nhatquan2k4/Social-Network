import { Request, Response } from 'express';
import { ShareService } from '../../services/Post/shareService';
import { Types } from 'mongoose';

const shareService = new ShareService();

/**
 * Share một bài viết
 */
export const sharePost = async (req: Request, res: Response) => {
    try {
        const { originalPostId, caption } = req.body;
        const userId = req.user!._id;

        if (!originalPostId) {
            return res.status(400).json({ message: 'Vui long cung cap ID bai viet' });
        }

        if (!Types.ObjectId.isValid(originalPostId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const result = await shareService.sharePost(userId, originalPostId, caption);

        return res.status(201).json({
            message: 'Share bai viet thanh cong',
            share: result.share,
            sharePost: result.sharePost
        });
    } catch (error: any) {
        console.error('Loi khi share bai viet:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Ban da share bai viet nay roi') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy thông tin chi tiết một share
 */
export const getShareById = async (req: Request, res: Response) => {
    try {
        const shareId = req.params.shareId as string;

        if (!Types.ObjectId.isValid(shareId)) {
            return res.status(400).json({ message: 'ID share khong hop le' });
        }

        const share = await shareService.getShareById(shareId, true);

        return res.status(200).json({ share });
    } catch (error: any) {
        console.error('Loi khi lay thong tin share:', error);
        if (error.message === 'Share khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Cập nhật caption của share
 */
export const updateShare = async (req: Request, res: Response) => {
    try {
        const shareId = req.params.shareId as string;
        const { caption } = req.body;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(shareId)) {
            return res.status(400).json({ message: 'ID share khong hop le' });
        }

        if (caption === undefined) {
            return res.status(400).json({ message: 'Vui long cung cap caption' });
        }

        // Kiểm tra quyền sở hữu
        const existingShare = await shareService.getShareById(shareId);

        if (existingShare.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen cap nhat share nay' });
        }

        const updatedShare = await shareService.updateShare(shareId, { caption });

        return res.status(200).json({
            message: 'Cap nhat share thanh cong',
            share: updatedShare
        });
    } catch (error: any) {
        console.error('Loi khi cap nhat share:', error);
        if (error.message === 'Share khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Xóa share (bỏ share)
 */
export const deleteShare = async (req: Request, res: Response) => {
    try {
        const shareId = req.params.shareId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(shareId)) {
            return res.status(400).json({ message: 'ID share khong hop le' });
        }

        // Kiểm tra quyền sở hữu
        const existingShare = await shareService.getShareById(shareId);

        if (existingShare.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen xoa share nay' });
        }

        await shareService.deleteShare(shareId);

        return res.status(200).json({ message: 'Xoa share thanh cong' });
    } catch (error: any) {
        console.error('Loi khi xoa share:', error);
        if (error.message === 'Share khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách shares của một bài viết
 */
export const getSharesByPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const { limit, skip } = req.query;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);

        const result = await shareService.getSharesByPost(postId, options);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi lay danh sach shares:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách shares của một người dùng
 */
export const getSharesByUser = async (req: Request, res: Response) => {
    try {
        const userId = req.params.userId as string;
        const { limit, skip } = req.query;

        if (!Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ message: 'ID nguoi dung khong hop le' });
        }

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);

        const result = await shareService.getSharesByUserId(userId, options);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi lay danh sach shares:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Kiểm tra user hiện tại đã share post chưa
 */
export const checkUserShared = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const result = await shareService.hasUserShared(userId, postId);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi kiem tra share:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
