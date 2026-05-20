import type { NotificationServiceInterface } from '../../notifications/notifications.service.interface.js';
import type { PostRepositoryInterface } from '../shared/posts.repo.interface.js';
import type { CommentService } from './comment.service.js';

export type CommentPostRepository = Pick<
    PostRepositoryInterface,
    'findRawById' | 'addComment' | 'getComments' | 'save'
>;
export type CommentNotificationService = Pick<
    NotificationServiceInterface,
    'createNotification'
>;

export interface CommentServiceDependencies {
    postRepository?: CommentPostRepository;
    notificationService?: CommentNotificationService;
}

export interface CommentServiceInterface {
    addComment: CommentService['addComment'];
    getComments: CommentService['getComments'];
    updateComment: CommentService['updateComment'];
    deleteComment: CommentService['deleteComment'];
}
