import { Types } from 'mongoose';
import {
    BlockRepository,
    FriendRepository,
} from '../../friends/shared/friends.repo.js';
import { BlockedInteractionError } from '../../friends/shared/friends.errors.js';
import { MediaService } from '../../media/upload/upload.service.js';
import { PostRepository } from '../../posts/shared/posts.repo.js';
import { UserRepository } from '../shared/users.repo.js';
import { ensureValidObjectId } from '../shared/users.util.js';
import { UserNotFoundError } from '../shared/users.errors.js';
import { UpdateProfileDto } from './profile.dto.js';
import type {
    ProfileBlockRepository,
    ProfileFriendRepository,
    ProfileMediaService,
    ProfilePostRepository,
    ProfileServiceDependencies,
    ProfileServiceInterface,
    ProfileUserRepository,
} from './profile.service.interface.js';

export class ProfileService implements ProfileServiceInterface {
    private userRepository: ProfileUserRepository;
    private postRepository: ProfilePostRepository;
    private friendRepository: ProfileFriendRepository;
    private blockRepository: ProfileBlockRepository;
    private mediaService: ProfileMediaService;

    constructor(dependencies: ProfileServiceDependencies = {}) {
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.postRepository = dependencies.postRepository ?? new PostRepository();
        this.friendRepository = dependencies.friendRepository ?? new FriendRepository();
        this.blockRepository = dependencies.blockRepository ?? new BlockRepository();
        this.mediaService = dependencies.mediaService ?? new MediaService();
    }

    getMe(user: Express.Request["user"]) {
        if (!user) {
            throw new UserNotFoundError();
        }

        return user;
    }

    async getUserProfile(userId: string, requesterId: Types.ObjectId) {
        ensureValidObjectId(userId);
        const normalizedUserId = new Types.ObjectId(userId);

        const [user, postsCount, friendsCount, blockRelation] = await Promise.all([
            this.userRepository.findProfileById(normalizedUserId),
            this.postRepository.countByAuthorId(normalizedUserId),
            this.friendRepository.countByUserId(normalizedUserId),
            requesterId.toString() === normalizedUserId.toString()
                ? Promise.resolve(null)
                : this.blockRepository.findBetweenUsers(requesterId, normalizedUserId),
        ]);

        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }

        if (blockRelation) {
            throw new BlockedInteractionError();
        }

        return {
            user,
            stats: {
                postsCount,
                friendsCount,
            },
        };
    }

    async updateMe(userId: Types.ObjectId, payload: UpdateProfileDto) {
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

    async updateAvatar(userId: Types.ObjectId, files: Express.Multer.File[]) {
        if (!files.length) {
            throw new Error('Khong tim thay file avatar');
        }

        const uploaded = await this.mediaService.uploadFiles(
            [files[0] as Express.Multer.File],
            'avatar',
            userId.toString(),
        );
        const avatar = uploaded[0];

        if (!avatar) {
            throw new Error('Khong the upload avatar');
        }

        const user = await this.userRepository.updateAvatar(userId, {
            avatarUrl: avatar.mediaUrl,
            avatarPublicId: avatar.objectKey,
            avatarBucket: avatar.bucket,
            avatarObjectKey: avatar.objectKey,
        });

        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }

        return user;
    }
}
