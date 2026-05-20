import type { NotificationRepository } from './notifications.repo.js';

export interface NotificationRepositoryInterface extends Pick<
    NotificationRepository,
    | 'create'
    | 'findByRecipient'
    | 'countByRecipient'
    | 'markRead'
    | 'markAllRead'
> {}
