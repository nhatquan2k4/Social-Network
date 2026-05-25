import type { NotificationRepositoryInterface } from './notifications.repo.interface.js';
import type { NotificationService } from './notifications.service.js';

export type NotificationServiceRepository = Pick<
    NotificationRepositoryInterface,
    | 'create'
    | 'findByRecipient'
    | 'countByRecipient'
    | 'markRead'
    | 'markAllRead'
>;

export interface NotificationServiceDependencies {
    notificationRepository?: NotificationServiceRepository;
}

export interface NotificationServiceInterface {
    saveFcmToken: NotificationService['saveFcmToken'];
    createNotification: NotificationService['createNotification'];
    getMyNotifications: NotificationService['getMyNotifications'];
    markAsRead: NotificationService['markAsRead'];
    markAllAsRead: NotificationService['markAllAsRead'];
    sendTestNotification: NotificationService['sendTestNotification'];
}
