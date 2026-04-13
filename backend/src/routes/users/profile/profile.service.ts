import { Types } from 'mongoose';
import { FriendRepository } from '../../friends/shared/friends.repo';
import { MediaService } from '../../media/upload/upload.service';
import { PostRepository } from '../../posts/shared/posts.repo';
import { UserRepository } from '../shared/users.repo';
import { ensureValidObjectId } from '../shared/users.util';
import { UserNotFoundError } from '../shared/users.errors';
import { UpdateProfileDto } from './profile.dto';

export class ProfileService {
    private userRepository: UserRepository;
    private postRepository: PostRepository;
    private friendRepository: FriendRepository;
    private mediaService: MediaService;

    constructor() {
        this.userRepository = new UserRepository();
        this.postRepository = new PostRepository();
        this.friendRepository = new FriendRepository();
        this.mediaService = new MediaService();
    }

    getMe(user: Express.Request["user"]) {
        if (!user) {
            throw new UserNotFoundError();
        }

        return user;
    }

    async getUserProfile(userId: string) {
        ensureValidObjectId(userId);
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
