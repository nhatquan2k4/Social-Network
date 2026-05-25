import type { ConversationRepositoryInterface } from '../../conversations/shared/conversations.repo.interface.js';
import type { MessageRepositoryInterface } from '../shared/messages.repo.interface.js';
import type { ReadService } from './read.service.js';

export type ReadMessageRepository = Pick<
    MessageRepositoryInterface,
    | 'findByIdAndConversationId'
    | 'markAsRead'
    | 'markAllAsReadByConversation'
    | 'findByConversationId'
>;
export type ReadConversationRepository = Pick<
    ConversationRepositoryInterface,
    'updateMarkAsSeen'
>;

export interface ReadServiceDependencies {
    messageRepository?: ReadMessageRepository;
    conversationRepository?: ReadConversationRepository;
}

export interface ReadServiceInterface {
    markMessageAsRead: ReadService['markMessageAsRead'];
    markMessagesAsReadUntil: ReadService['markMessagesAsReadUntil'];
    getConversationMessages: ReadService['getConversationMessages'];
}
