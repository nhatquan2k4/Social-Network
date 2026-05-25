import type { NotificationServiceInterface } from '../../notifications/notifications.service.interface.js';
import type { PostRepositoryInterface } from '../shared/posts.repo.interface.js';
import type { LikeService } from './like.service.js';

export type LikePostRepository = Pick<
    PostRepositoryInterface,
    'findRawById' | 'toggleLike' | 'findById'
>;
export type LikeNotificationService = Pick<
    NotificationServiceInterface,
    'createNotification'
>;

export interface LikeServiceDependencies {
    postRepository?: LikePostRepository;
    notificationService?: LikeNotificationService;
}

export interface LikeServiceInterface {
    toggleLike: LikeService['toggleLike'];
}
