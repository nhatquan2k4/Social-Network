import type { MessageRepository } from './messages.repo.js';

export interface MessageRepositoryInterface extends Pick<
    MessageRepository,
    | 'create'
    | 'findByConversationId'
    | 'findByIdAndConversationId'
    | 'findById'
    | 'findLatestByConversationId'
    | 'deleteByIdAndConversationId'
    | 'upsertReaction'
    | 'removeReaction'
    | 'markAsRead'
    | 'markAllAsReadByConversation'
    | 'deleteByConversationId'
> {}
