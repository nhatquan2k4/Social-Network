import { Request, Response } from 'express';
import { SearchService } from './search.service.js';

const searchService = new SearchService();

export const searchUsers = async (req: Request, res: Response) => {
    try {
        const currentUserId = req.user!._id;

        const result = await searchService.searchUsers(
            req.query.name,
            req.query.page,
            req.query.limit,
            currentUserId,
        );

        return res.status(200).json(result);
    } catch (error: any) {
        console.error('Loi khi tim kiem user', error);
        if (error instanceof Error && error.message.includes('name la bat buoc')) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};
