import type { ConversationRepositoryInterface } from '../../conversations/shared/conversations.repo.interface.js';
import type { NotificationServiceInterface } from '../../notifications/notifications.service.interface.js';
import type { MessageRepositoryInterface } from '../shared/messages.repo.interface.js';
import type { MessageService } from './message.service.js';

export type MessageConversationRepository = Pick<
    ConversationRepositoryInterface,
    'findById' | 'create'
>;
export type MessageServiceRepository = Pick<MessageRepositoryInterface, 'create'>;
export type MessageNotificationService = Pick<
    NotificationServiceInterface,
    'createNotification'
>;

export interface MessageServiceDependencies {
    conversationRepository?: MessageConversationRepository;
    messageRepository?: MessageServiceRepository;
    notificationService?: MessageNotificationService;
}

export interface MessageServiceInterface {
    sendDirectMessage: MessageService['sendDirectMessage'];
    sendGroupMessage: MessageService['sendGroupMessage'];
}
