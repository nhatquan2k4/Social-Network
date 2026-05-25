import type { NotificationServiceInterface } from '../../notifications/notifications.service.interface.js';
import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type {
    FriendRepositoryInterface,
    FriendRequestRepositoryInterface,
} from '../shared/friends.repo.interface.js';
import type { RequestService } from './request.service.js';

export type RequestFriendRepository = Pick<
    FriendRepositoryInterface,
    'findByUsers' | 'create'
>;
export type RequestFriendRequestRepository = Pick<
    FriendRequestRepositoryInterface,
    | 'findBetweenUsers'
    | 'create'
    | 'findById'
    | 'deleteById'
    | 'findSentByUserId'
    | 'findReceivedByUserId'
>;
export type RequestUserRepository = Pick<
    UserRepositoryInterface,
    'exists' | 'findByIdWithFields'
>;
export type RequestNotificationService = Pick<
    NotificationServiceInterface,
    'createNotification'
>;

export interface RequestServiceDependencies {
    friendRepository?: RequestFriendRepository;
    friendRequestRepository?: RequestFriendRequestRepository;
    userRepository?: RequestUserRepository;
    notificationService?: RequestNotificationService;
}

export interface RequestServiceInterface {
    sendFriendRequest: RequestService['sendFriendRequest'];
    acceptFriendRequest: RequestService['acceptFriendRequest'];
    rejectFriendRequest: RequestService['rejectFriendRequest'];
    getAllFriendRequests: RequestService['getAllFriendRequests'];
}
