import { Types } from 'mongoose';
import { NotificationRepository } from './notifications.repo.js';
import { emitNotificationNew } from '../../shared/socket/socket.emitter.js';
import { UserModel } from '../users/shared/users.model.js';
import { fcm } from '../../shared/config/firebase.js';

export type NotificationType =
  | 'FRIEND_REQUEST'
  | 'FRIEND_ACCEPTED'
  | 'POST_LIKED'
  | 'POST_COMMENTED'
  | 'COMMENT_REPLIED';

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

export type FcmPlatform = 'android' | 'ios' | 'web';

export class NotificationService {
  private notificationRepository: NotificationRepository;

  constructor() {
    this.notificationRepository = new NotificationRepository();
  }

  async saveFcmToken(
    userId: Types.ObjectId,
    token: string,
    platform: FcmPlatform = 'android',
  ) {
    if (!token) {
      throw new Error('Thieu FCM token');
    }

    const safePlatform: FcmPlatform =
      platform === 'ios' || platform === 'web' || platform === 'android'
        ? platform
        : 'android';

    await UserModel.updateOne(
      { _id: userId },
      {
        $pull: {
          fcmTokens: {
            token,
          },
        },
      },
    );

    await UserModel.updateOne(
      { _id: userId },
      {
        $push: {
          fcmTokens: {
            token,
            platform: safePlatform,
            updatedAt: new Date(),
          },
        },
      },
    );

    return {
      message: 'Luu FCM token thanh cong',
    };
  }

  async createNotification(params: CreateNotificationParams) {
    if (params.recipientId.toString() === params.actorId.toString()) {
      return null;
    }

    const notification = await this.notificationRepository.create({
      recipientId: params.recipientId,
      actorId: params.actorId,
      type: params.type,
      title: params.title,
      body: params.body,
      entityType: params.entityType,
      entityId: params.entityId,
      metadata: params.metadata,
    });

    emitNotificationNew(params.recipientId.toString(), notification);

    try {
      const recipient = await UserModel.findById(params.recipientId).select('fcmTokens');
      
      if (recipient && recipient.fcmTokens && recipient.fcmTokens.length > 0) {
        // 🔍 Bước 1: Tìm tên hiển thị của người tương tác (actor)
        const actor = await UserModel.findById(params.actorId).select('displayName');
        const actorName = actor?.displayName || 'Ai đó';

        // ✍️ Bước 2: Ghép tên vào trước nội dung hành động gốc
        const fullBody = `${actorName} ${params.body}`;

        const sendPromises = recipient.fcmTokens.map((fcmTokenObj: any) => {
          const message = {
            notification: {
              title: params.title,
              body: fullBody, // 🎯 Sử dụng nội dung đầy đủ đã có tên ở đây
            },
            token: fcmTokenObj.token,
          };
          return fcm.send(message).catch((err) => {
            console.error(`Lỗi gửi FCM đến token: ${fcmTokenObj.token}`, err);
          });
        });

        await Promise.all(sendPromises);
      }
    } catch (fcmError) {
      console.error('Lỗi khi xử lý gửi Push Notification:', fcmError);
    }

    return notification;
  }

  async getMyNotifications(
    userId: Types.ObjectId,
    page: number,
    limit: number,
    unreadOnly: boolean,
  ) {
    const safePage = Math.max(1, page);
    const safeLimit = Math.max(1, Math.min(limit, 50));
    const skip = (safePage - 1) * safeLimit;

    const [items, total, unreadCount] = await Promise.all([
      this.notificationRepository.findByRecipient(
        userId,
        skip,
        safeLimit,
        unreadOnly,
      ),
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
    const updated = await this.notificationRepository.markRead(
      notificationId,
      userId,
    );

    if (!updated) {
      throw new Error('Thong bao khong ton tai');
    }

    return updated;
  }

  async markAllAsRead(userId: Types.ObjectId) {
    return this.notificationRepository.markAllRead(userId);
  }

  // Thêm hàm test này vào trong class
  async sendTestNotification(deviceToken: string) {
    const message = {
      notification: {
        title: 'Thông báo từ Backend! 🚀',
        body: 'Cấu hình FCM đã thành công ',
      },
      token: deviceToken,
    };

    // Ra lệnh cho Firebase gửi thông báo
    return await fcm.send(message);
  }
}