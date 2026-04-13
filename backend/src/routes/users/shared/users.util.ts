import { Types } from 'mongoose';
import {
    DEFAULT_POSTS_LIMIT,
    DEFAULT_POSTS_PAGE,
    MAX_POSTS_LIMIT,
} from './users.constants';

export const ensureValidObjectId = (userId: string) => {
    if (!Types.ObjectId.isValid(userId)) {
        throw new Error('userId khong hop le');
    }
};

export const normalizePagination = (page?: number, limit?: number) => {
    const safePage = Math.max(DEFAULT_POSTS_PAGE, Number(page || DEFAULT_POSTS_PAGE));
    const safeLimit = Math.max(
        1,
        Math.min(Number(limit || DEFAULT_POSTS_LIMIT), MAX_POSTS_LIMIT),
    );

    return {
        page: safePage,
        limit: safeLimit,
        skip: (safePage - 1) * safeLimit,
    };
};
