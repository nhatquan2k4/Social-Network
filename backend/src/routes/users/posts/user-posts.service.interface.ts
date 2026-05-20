import type { BlockRepositoryInterface } from '../../friends/shared/friends.repo.interface.js';
import type { PostRepositoryInterface } from '../../posts/shared/posts.repo.interface.js';
import type { UserRepositoryInterface } from '../shared/users.repo.interface.js';
import type { UserPostsService } from './user-posts.service.js';

export type UserPostsUserRepository = Pick<UserRepositoryInterface, 'exists'>;
export type UserPostsPostRepository = Pick<
    PostRepositoryInterface,
    'findByAuthorId' | 'countByAuthorId'
>;
export type UserPostsBlockRepository = Pick<BlockRepositoryInterface, 'findBetweenUsers'>;

export interface UserPostsServiceDependencies {
    userRepository?: UserPostsUserRepository;
    postRepository?: UserPostsPostRepository;
    blockRepository?: UserPostsBlockRepository;
}

export interface UserPostsServiceInterface {
    execute: UserPostsService['execute'];
}
