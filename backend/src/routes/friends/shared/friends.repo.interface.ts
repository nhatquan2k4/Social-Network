import type {
    BlockRepository,
    FriendRepository,
    FriendRequestRepository,
} from './friends.repo.js';

export interface FriendRepositoryInterface extends Pick<
    FriendRepository,
    | 'findByUsers'
    | 'create'
    | 'findAllByUserId'
    | 'countByUserId'
    | 'getFriendIds'
> {}

export interface FriendRequestRepositoryInterface extends Pick<
    FriendRequestRepository,
    | 'findBetweenUsers'
    | 'create'
    | 'findById'
    | 'deleteById'
    | 'findSentByUserId'
    | 'findReceivedByUserId'
> {}

export interface BlockRepositoryInterface extends Pick<
    BlockRepository,
    | 'findByUsers'
    | 'findBetweenUsers'
    | 'create'
    | 'deleteByUsers'
    | 'findBlockedByUserId'
> {}
