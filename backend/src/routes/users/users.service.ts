import { UserRepository } from './users.repo';
import { Types } from 'mongoose';
import { PostRepository } from '../posts/posts.repo';
import { FriendRepository } from '../friends/friends.repo';
import { buildMediaUrl } from '../../shared/config/minio';

interface UpdateProfilePayload {
    hasDisplayNameField: boolean;
    displayName?: string;
    hasBioField: boolean;
    bio?: string;
    hasPhoneField: boolean;
    phone?: string;
}

export class UserService {
    private userRepository: UserRepository;
    private postRepository: PostRepository;
    private friendRepository: FriendRepository;

    constructor() {
        this.userRepository = new UserRepository();
        this.postRepository = new PostRepository();
        this.friendRepository = new FriendRepository();
    }

    private ensureValidObjectId(userId: string) {
        if (!Types.ObjectId.isValid(userId)) {
            throw new Error('userId khong hop le');
        }
    }

    async getUserProfileWithStats(userId: string) {
        this.ensureValidObjectId(userId);

        const normalizedUserId = new Types.ObjectId(userId);
        const [user, postsCount, friendsCount] = await Promise.all([
            this.userRepository.findProfileById(normalizedUserId),
            this.postRepository.countByAuthorId(normalizedUserId),
            this.friendRepository.countByUserId(normalizedUserId),
        ]);

        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }

        return {
            user,
            stats: {
                postsCount,
                friendsCount,
            },
        };
    }

    async getPostsByUserId(userId: string, page: number, limit: number) {
        this.ensureValidObjectId(userId);
        const normalizedUserId = new Types.ObjectId(userId);

        const exists = await this.userRepository.exists(normalizedUserId);
        if (!exists) {
            throw new Error('Nguoi dung khong ton tai');
        }

        const safePage = Math.max(1, page);
        const safeLimit = Math.max(1, Math.min(limit, 50));
        const skip = (safePage - 1) * safeLimit;

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

    async updateMyProfile(userId: Types.ObjectId, payload: UpdateProfilePayload) {
        const setData: Record<string, unknown> = {};
        const unsetFields: string[] = [];

        if (payload.hasDisplayNameField) {
            const normalizedDisplayName = String(payload.displayName || '').trim();
            if (!normalizedDisplayName) {
                throw new Error('DisplayName khong duoc de trong');
            }
            setData.displayName = normalizedDisplayName;
        }

        if (payload.hasBioField) {
            const normalizedBio = String(payload.bio || '').trim();
            if (normalizedBio) {
                setData.bio = normalizedBio;
            } else {
                unsetFields.push('bio');
            }
        }

        if (payload.hasPhoneField) {
            const normalizedPhone = String(payload.phone || '').trim();
            if (normalizedPhone) {
                setData.phone = normalizedPhone;
            } else {
                unsetFields.push('phone');
            }
        }

        if (Object.keys(setData).length === 0 && unsetFields.length === 0) {
            throw new Error('Khong co du lieu cap nhat');
        }

        const user = await this.userRepository.updateProfile(userId, setData, unsetFields);
        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }

        return user;
    }

    async getUserById(userId: Types.ObjectId) {
        const user = await this.userRepository.findById(userId);
        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }
        return user;
    }

    async updateAvatar(
        userId: Types.ObjectId,
        avatarData: { avatarUrl: string; avatarPublicId: string; avatarBucket: string; avatarObjectKey: string },
    ) {
        const user = await this.userRepository.updateAvatar(userId, avatarData);
        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }
        return user;
    }
}
