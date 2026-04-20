import { Types } from 'mongoose';
import { buildMediaUrl } from '../../../shared/config/minio.js';
import { PostRepository } from '../../posts/shared/posts.repo.js';
import { UserRepository } from '../shared/users.repo.js';
import { ensureValidObjectId, normalizePagination } from '../shared/users.util.js';

export class UserPostsService {
    private userRepository: UserRepository;
    private postRepository: PostRepository;

    constructor() {
        this.userRepository = new UserRepository();
        this.postRepository = new PostRepository();
    }

    async execute(userId: string, page: number, limit: number) {
        ensureValidObjectId(userId);
        const normalizedUserId = new Types.ObjectId(userId);

        const exists = await this.userRepository.exists(normalizedUserId);
        if (!exists) {
            throw new Error('Nguoi dung khong ton tai');
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
