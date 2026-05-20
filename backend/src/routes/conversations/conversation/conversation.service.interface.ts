import type { MessageRepositoryInterface } from '../../messages/shared/messages.repo.interface.js';
import type { ConversationRepositoryInterface } from '../shared/conversations.repo.interface.js';
import type { ConversationService } from './conversation.service.js';

export type ConversationServiceConversationRepository = Pick<
    ConversationRepositoryInterface,
    | 'findDirectConversation'
    | 'create'
    | 'findByUserId'
    | 'findUserConversationIds'
    | 'findByIdLean'
    | 'updateMarkAsSeen'
    | 'findById'
    | 'deleteById'
>;
export type ConversationServiceMessageRepository = Pick<
    MessageRepositoryInterface,
    'deleteByConversationId'
>;

export interface ConversationServiceDependencies {
    conversationRepository?: ConversationServiceConversationRepository;
    messageRepository?: ConversationServiceMessageRepository;
}

export interface ConversationServiceInterface {
    createConversation: ConversationService['createConversation'];
    getConversations: ConversationService['getConversations'];
    getUserConversationsForSocketIO: ConversationService['getUserConversationsForSocketIO'];
    markAsSeen: ConversationService['markAsSeen'];
    leaveGroupConversation: ConversationService['leaveGroupConversation'];
}
