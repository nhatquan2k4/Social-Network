import type {
    BlockRepositoryInterface,
    FriendRepositoryInterface,
} from '../../friends/shared/friends.repo.interface.js';
import type { MediaServiceInterface } from '../../media/upload/upload.service.interface.js';
import type { PostRepositoryInterface } from '../../posts/shared/posts.repo.interface.js';
import type { UserRepositoryInterface } from '../shared/users.repo.interface.js';
import type { ProfileService } from './profile.service.js';

export type ProfileUserRepository = Pick<
    UserRepositoryInterface,
    'findProfileById' | 'updateProfile' | 'updateAvatar'
>;
export type ProfilePostRepository = Pick<PostRepositoryInterface, 'countByAuthorId'>;
export type ProfileFriendRepository = Pick<FriendRepositoryInterface, 'countByUserId'>;
export type ProfileBlockRepository = Pick<BlockRepositoryInterface, 'findBetweenUsers'>;
export type ProfileMediaService = Pick<MediaServiceInterface, 'uploadFiles'>;

export interface ProfileServiceDependencies {
    userRepository?: ProfileUserRepository;
    postRepository?: ProfilePostRepository;
    friendRepository?: ProfileFriendRepository;
    blockRepository?: ProfileBlockRepository;
    mediaService?: ProfileMediaService;
}

export interface ProfileServiceInterface {
    getMe: ProfileService['getMe'];
    getUserProfile: ProfileService['getUserProfile'];
    updateMe: ProfileService['updateMe'];
    updateAvatar: ProfileService['updateAvatar'];
}
