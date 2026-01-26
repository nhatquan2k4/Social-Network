import { Request, Response } from 'express';
import { CommentService } from '../../services/Post/commentService';
import { Types } from 'mongoose';

const commentService = new CommentService();

/**
 * Tạo bình luận mới
 */
export const createComment = async (req: Request, res: Response) => {
    try {
        const { postId, content, parentCommentId } = req.body;
        const userId = req.user!._id;

        if (!postId || !content) {
            return res.status(400).json({ message: 'Vui long cung cap day du thong tin' });
        }

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        if (parentCommentId && !Types.ObjectId.isValid(parentCommentId)) {
            return res.status(400).json({ message: 'ID comment goc khong hop le' });
        }

        const newComment = await commentService.createComment({
            postId,
            userId,
            content,
            parentCommentId: parentCommentId || null
        });

        return res.status(201).json({
            message: 'Tao binh luan thanh cong',
            comment: newComment
        });
    } catch (error: any) {
        console.error('Loi khi tao binh luan:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Comment goc khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy thông tin chi tiết bình luận
 */
export const getCommentById = async (req: Request, res: Response) => {
    try {
        const commentId = req.params.commentId as string;

        if (!Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({ message: 'ID binh luan khong hop le' });
        }

        const comment = await commentService.getCommentById(commentId, true);

        return res.status(200).json({ comment });
    } catch (error: any) {
        console.error('Loi khi lay thong tin binh luan:', error);
        if (error.message === 'Comment khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Cập nhật bình luận
 */
export const updateComment = async (req: Request, res: Response) => {
    try {
        const commentId = req.params.commentId as string;
        const { content } = req.body;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({ message: 'ID binh luan khong hop le' });
        }

        if (!content) {
            return res.status(400).json({ message: 'Vui long cung cap noi dung' });
        }

        // Kiểm tra quyền sở hữu
        const existingComment = await commentService.getCommentById(commentId);

        if (existingComment.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen cap nhat binh luan nay' });
        }

        const updatedComment = await commentService.updateComment(commentId, { content });

        return res.status(200).json({
            message: 'Cap nhat binh luan thanh cong',
            comment: updatedComment
        });
    } catch (error: any) {
        console.error('Loi khi cap nhat binh luan:', error);
        if (error.message === 'Comment khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Xóa bình luận
 */
export const deleteComment = async (req: Request, res: Response) => {
    try {
        const commentId = req.params.commentId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({ message: 'ID binh luan khong hop le' });
        }

        // Kiểm tra quyền sở hữu
        const existingComment = await commentService.getCommentById(commentId);

        if (existingComment.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen xoa binh luan nay' });
        }

        await commentService.deleteComment(commentId);

        return res.status(200).json({ message: 'Xoa binh luan thanh cong' });
    } catch (error: any) {
        console.error('Loi khi xoa binh luan:', error);
        if (error.message === 'Comment khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách bình luận của bài viết
 */
export const getCommentsByPost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const { limit, skip, sortOrder } = req.query;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);
        if (sortOrder) options.sortOrder = sortOrder as 'asc' | 'desc';

        const result = await commentService.getCommentsByPostId(postId, options);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi lay danh sach binh luan:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách replies của một bình luận
 */
export const getRepliesByComment = async (req: Request, res: Response) => {
    try {
        const commentId = req.params.commentId as string;
        const { limit, skip } = req.query;

        if (!Types.ObjectId.isValid(commentId)) {
            return res.status(400).json({ message: 'ID binh luan khong hop le' });
        }

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);

        const result = await commentService.getReplies(commentId, options);

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi lay danh sach replies:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
