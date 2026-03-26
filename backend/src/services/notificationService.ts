import { Types } from 'mongoose';
import { NotificationRepository } from '../repositories/notificationRepository';

export type NotificationType = 'FRIEND_REQUEST' | 'FRIEND_ACCEPTED' | 'POST_LIKED' | 'POST_COMMENTED' | 'COMMENT_REPLIED';

interface CreateNotificationParams {
  recipientId: Types.ObjectId;
  actorId: Types.ObjectId;
  type: NotificationType;
  title: string;
  body: string;
  entityType?: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
}

export class NotificationService {
  private notificationRepository: NotificationRepository;

  constructor() {
    this.notificationRepository = new NotificationRepository();
  }

  async createNotification(params: CreateNotificationParams) {
    if (params.recipientId.toString() === params.actorId.toString()) {
      return null;
    }

    return this.notificationRepository.create({
      recipientId: params.recipientId,
      actorId: params.actorId,
      type: params.type,
      title: params.title,
      body: params.body,
      entityType: params.entityType,
      entityId: params.entityId,
      metadata: params.metadata,
    });
  }

  async getMyNotifications(userId: Types.ObjectId, page: number, limit: number, unreadOnly: boolean) {
    const safePage = Math.max(1, page);
    const safeLimit = Math.max(1, Math.min(limit, 50));
    const skip = (safePage - 1) * safeLimit;

    const [items, total, unreadCount] = await Promise.all([
      this.notificationRepository.findByRecipient(userId, skip, safeLimit, unreadOnly),
      this.notificationRepository.countByRecipient(userId, unreadOnly),
      this.notificationRepository.countByRecipient(userId, true),
    ]);

    return {
      items,
      page: safePage,
      limit: safeLimit,
      total,
      unreadCount,
      hasMore: skip + items.length < total,
    };
  }

  async markAsRead(notificationId: string, userId: Types.ObjectId) {
    const updated = await this.notificationRepository.markRead(notificationId, userId);

    if (!updated) {
      throw new Error('Thong bao khong ton tai');
    }

    return updated;
  }

  async markAllAsRead(userId: Types.ObjectId) {
    return this.notificationRepository.markAllRead(userId);
  }
}
