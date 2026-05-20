import type { FriendRepositoryInterface } from '../shared/friends.repo.interface.js';
import type { FriendService } from './friend.service.js';

export type FriendServiceRepository = Pick<FriendRepositoryInterface, 'findAllByUserId'>;

export interface FriendServiceDependencies {
    friendRepository?: FriendServiceRepository;
}

export interface FriendServiceInterface {
    getAllFriends: FriendService['getAllFriends'];
}
