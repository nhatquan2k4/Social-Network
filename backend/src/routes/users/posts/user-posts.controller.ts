import { Request, Response } from 'express';
import { UserPostsService } from './user-posts.service.js';

const userPostsService = new UserPostsService();

export const getUserPosts = async (req: Request, res: Response) => {
    try {
        const { userId } = req.params;
        const page = Number(req.query.page || '1');
        const limit = Number(req.query.limit || '20');

        const data = await userPostsService.execute(userId as string, page, limit);

        return res.status(200).json({ data });
    } catch (error: any) {
        console.error('Loi khi lay post cua user:', error);
        if (error.message === 'userId khong hop le') {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }

        return res.status(500).json({ message: 'Loi server' });
    }
};
