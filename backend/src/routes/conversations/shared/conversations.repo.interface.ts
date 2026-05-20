import type { ConversationRepository } from './conversations.repo.js';

export interface ConversationRepositoryInterface extends Pick<
    ConversationRepository,
    | 'findDirectConversation'
    | 'create'
    | 'findById'
    | 'findByIdAndPopulate'
    | 'findByUserId'
    | 'findUserConversationIds'
    | 'findByIdLean'
    | 'updateMarkAsSeen'
    | 'deleteById'
> {}
