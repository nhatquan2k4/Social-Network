import type { FriendRepositoryInterface } from '../../friends/shared/friends.repo.interface.js';
import type { PostRepositoryInterface } from '../shared/posts.repo.interface.js';
import type { FeedService } from './feed.service.js';

export type FeedFriendRepository = Pick<FriendRepositoryInterface, 'getFriendIds'>;
export type FeedPostRepository = Pick<PostRepositoryInterface, 'findFeed' | 'countAll'>;

export interface FeedServiceDependencies {
    friendRepository?: FeedFriendRepository;
    postRepository?: FeedPostRepository;
}

export interface FeedServiceInterface {
    getFeed: FeedService['getFeed'];
}
