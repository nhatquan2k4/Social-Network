import { Types } from 'mongoose';
import { buildMediaUrl } from '../../media/shared/media.repo.js';
import {
    BlockRepository,
} from '../../friends/shared/friends.repo.js';
import { BlockedInteractionError } from '../../friends/shared/friends.errors.js';
import { PostRepository } from '../../posts/shared/posts.repo.js';
import { UserRepository } from '../shared/users.repo.js';
import { ensureValidObjectId, normalizePagination } from '../shared/users.util.js';
import type {
    UserPostsBlockRepository,
    UserPostsPostRepository,
    UserPostsServiceDependencies,
    UserPostsServiceInterface,
    UserPostsUserRepository,
} from './user-posts.service.interface.js';

export class UserPostsService implements UserPostsServiceInterface {
    private userRepository: UserPostsUserRepository;
    private postRepository: UserPostsPostRepository;
    private blockRepository: UserPostsBlockRepository;

    constructor(dependencies: UserPostsServiceDependencies = {}) {
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.postRepository = dependencies.postRepository ?? new PostRepository();
        this.blockRepository = dependencies.blockRepository ?? new BlockRepository();
    }

    async execute(userId: string, requesterId: Types.ObjectId, page: number, limit: number) {
        ensureValidObjectId(userId);
        const normalizedUserId = new Types.ObjectId(userId);

        const [exists, blockRelation] = await Promise.all([
            this.userRepository.exists(normalizedUserId),
            requesterId.toString() === normalizedUserId.toString()
                ? Promise.resolve(null)
                : this.blockRepository.findBetweenUsers(requesterId, normalizedUserId),
        ]);
        if (!exists) {
            throw new Error('Nguoi dung khong ton tai');
        }

        if (blockRelation) {
            throw new BlockedInteractionError();
        }

        const { page: safePage, limit: safeLimit, skip } = normalizePagination(page, limit);

        const [items, total] = await Promise.all([
            this.postRepository.findByAuthorId(normalizedUserId, skip, safeLimit),
            this.postRepository.countByAuthorId(normalizedUserId),
        ]);

        const formattedItems = items.map((post: any) => ({
            ...post,
            media: (post.media || []).map((item: any) => ({
                ...item,
                mediaUrl: buildMediaUrl(item.bucket, item.objectKey),
            })),
            likesCount: (post.likes || []).length,
        }));

        return {
            items: formattedItems,
            page: safePage,
            limit: safeLimit,
            total,
            hasMore: skip + formattedItems.length < total,
        };
    }
}
