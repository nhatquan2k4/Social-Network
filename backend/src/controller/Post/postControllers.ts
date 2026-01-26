import { Request, Response } from 'express';
import { PostService } from '../../services/Post/postService';
import { FriendService } from '../../services/friendService';
import { Types } from 'mongoose';

const postService = new PostService();
const friendService = new FriendService();

/**
 * Tạo bài viết mới
 */
export const createPost = async (req: Request, res: Response) => {
    try {
        const { content, media, privacy } = req.body;
        const userId = req.user!._id;

        if (!content) {
            return res.status(400).json({ message: 'Vui long cung cap noi dung bai viet' });
        }

        const newPost = await postService.createPost({
            userId,
            content,
            media,
            privacy: privacy || 'public'
        });

        return res.status(201).json({
            message: 'Tao bai viet thanh cong',
            post: newPost
        });
    } catch (error: any) {
        console.error('Loi khi tao bai viet:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy thông tin chi tiết bài viết
 */
export const getPostById = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        const post = await postService.getPostById(postId, true);

        return res.status(200).json({ post });
    } catch (error: any) {
        console.error('Loi khi lay thong tin bai viet:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Cập nhật bài viết
 */
export const updatePost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const { content, media, privacy } = req.body;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        // Kiểm tra xem bài viết có tồn tại và thuộc về user không
        const existingPost = await postService.getPostById(postId);

        if (existingPost.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen cap nhat bai viet nay' });
        }

        const updateData: any = {};
        if (content !== undefined) updateData.content = content;
        if (media !== undefined) updateData.media = media;
        if (privacy !== undefined) updateData.privacy = privacy;

        const updatedPost = await postService.updatePost(postId, updateData);

        return res.status(200).json({
            message: 'Cap nhat bai viet thanh cong',
            post: updatedPost
        });
    } catch (error: any) {
        console.error('Loi khi cap nhat bai viet:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Xóa bài viết
 */
export const deletePost = async (req: Request, res: Response) => {
    try {
        const postId = req.params.postId as string;
        const userId = req.user!._id;

        if (!Types.ObjectId.isValid(postId)) {
            return res.status(400).json({ message: 'ID bai viet khong hop le' });
        }

        // Kiểm tra xem bài viết có tồn tại và thuộc về user không
        const existingPost = await postService.getPostById(postId);

        if (existingPost.userId.toString() !== userId.toString()) {
            return res.status(403).json({ message: 'Ban khong co quyen xoa bai viet nay' });
        }

        await postService.deletePost(postId);

        return res.status(200).json({ message: 'Xoa bai viet thanh cong' });
    } catch (error: any) {
        console.error('Loi khi xoa bai viet:', error);
        if (error.message === 'Post khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy danh sách bài viết của một người dùng
 */
export const getPostsByUserId = async (req: Request, res: Response) => {
    try {
        const userId = req.params.userId as string;
        const { limit, skip, privacy } = req.query;
        const currentUserId = req.user!._id;

        if (!Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ message: 'ID nguoi dung khong hop le' });
        }

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);

        const isOwnProfile = userId === currentUserId.toString();

        // Nếu xem profile của người khác
        if (!isOwnProfile) {
            // Kiểm tra có phải bạn bè không
            const friends = await friendService.getAllFriends(currentUserId);
            const friendIds = friends.map((f: any) => f._id.toString());
            const isFriend = friendIds.includes(userId);

            // Chỉ lấy public posts, hoặc friends posts nếu là bạn bè
            if (isFriend) {
                options.privacy = privacy || 'public,friends';
            } else {
                options.privacy = 'public';
            }
        } else {
            // Xem profile của chính mình: xem tất cả
            if (privacy) options.privacy = privacy as string;
        }

        const posts = await postService.findPostsByUserId(userId, options);

        // Filter thêm lần nữa để chắc chắn (chỉ cần nếu không phải own profile)
        let filteredPosts = posts;
        if (!isOwnProfile) {
            const friends = await friendService.getAllFriends(currentUserId);
            const friendIds = friends.map((f: any) => f._id.toString());
            const isFriend = friendIds.includes(userId);

            filteredPosts = posts.filter((post: any) => {
                if (post.privacy === 'public') return true;
                if (post.privacy === 'private') return false;
                if (post.privacy === 'friends') return isFriend;
                return false;
            });
        }

        const total = filteredPosts.length;

        return res.status(200).json({ posts: filteredPosts, total });
    } catch (error: any) {
        console.error('Loi khi lay danh sach bai viet:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

/**
 * Lấy tất cả bài viết (newsfeed)
 */
export const getAllPosts = async (req: Request, res: Response) => {
    try {
        const { limit, skip, privacy, sortBy, sortOrder } = req.query;
        const currentUserId = req.user!._id;

        const options: any = {};
        if (limit) options.limit = parseInt(limit as string);
        if (skip) options.skip = parseInt(skip as string);
        if (sortBy) options.sortBy = sortBy as string;
        if (sortOrder) options.sortOrder = sortOrder as 'asc' | 'desc';

        // Lấy danh sách bạn bè của user hiện tại
        const friends = await friendService.getAllFriends(currentUserId);
        const friendIds = friends.map((f: any) => f._id.toString());

        // Lấy tất cả posts
        const allPosts = await postService.findAll(options);

        // Filter posts theo quyền truy cập
        const filteredPosts = allPosts.filter((post: any) => {
            const postUserId = post.userId._id?.toString() || post.userId.toString();
            const isOwnPost = postUserId === currentUserId.toString();
            const isFriend = friendIds.includes(postUserId);

            // Bài viết của chính mình: luôn hiển thị
            if (isOwnPost) return true;

            // Public posts: ai cũng thấy
            if (post.privacy === 'public') return true;

            // Friends only: chỉ bạn bè mới thấy
            if (post.privacy === 'friends' && isFriend) return true;

            // Private: chỉ chủ nhân (đã check ở trên)
            return false;
        });

        // Apply privacy filter nếu có trong query
        const finalPosts = privacy
            ? filteredPosts.filter((post: any) => post.privacy === privacy)
            : filteredPosts;

        const total = finalPosts.length;

        return res.status(200).json({ posts: finalPosts, total });
    } catch (error: any) {
        console.error('Loi khi lay danh sach bai viet:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
