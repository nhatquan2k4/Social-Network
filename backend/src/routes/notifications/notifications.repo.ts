import { Types } from 'mongoose';
import { NotificationModel as Notification } from './notifications.model';

interface CreateNotificationInput {
	recipientId: Types.ObjectId;
	actorId: Types.ObjectId;
	type: 'FRIEND_REQUEST' | 'FRIEND_ACCEPTED' | 'POST_LIKED' | 'POST_COMMENTED' | 'COMMENT_REPLIED';
	title: string;
	body: string;
	entityType?: string;
	entityId?: string;
	metadata?: Record<string, unknown>;
}

export class NotificationRepository {
	async create(input: CreateNotificationInput) {
		return Notification.create(input);
	}

	async findByRecipient(recipientId: Types.ObjectId, skip: number, limit: number, unreadOnly: boolean) {
		const query: Record<string, unknown> = { recipientId };

		if (unreadOnly) {
			query.isRead = false;
		}

		return Notification.find(query)
			.sort({ createdAt: -1 })
			.skip(skip)
			.limit(limit)
			.populate('actorId', 'username displayName avatarUrl avatarBucket avatarObjectKey')
			.lean();
	}

	async countByRecipient(recipientId: Types.ObjectId, unreadOnly: boolean) {
		const query: Record<string, unknown> = { recipientId };

		if (unreadOnly) {
			query.isRead = false;
		}

		return Notification.countDocuments(query);
	}

	async markRead(notificationId: string, recipientId: Types.ObjectId) {
		return Notification.findOneAndUpdate(
			{ _id: notificationId, recipientId },
			{ $set: { isRead: true, readAt: new Date() } },
			{ new: true },
		)
			.populate('actorId', 'username displayName avatarUrl avatarBucket avatarObjectKey')
			.lean();
	}

	async markAllRead(recipientId: Types.ObjectId) {
		const result = await Notification.updateMany(
			{ recipientId, isRead: false },
			{ $set: { isRead: true, readAt: new Date() } },
		);

		return result.modifiedCount;
	}
}
