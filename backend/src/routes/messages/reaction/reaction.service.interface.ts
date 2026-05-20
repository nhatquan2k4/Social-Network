import type { ConversationRepositoryInterface } from '../../conversations/shared/conversations.repo.interface.js';
import type { MessageRepositoryInterface } from '../shared/messages.repo.interface.js';
import type { ReactionService } from './reaction.service.js';

export type ReactionConversationRepository = Pick<ConversationRepositoryInterface, 'findById'>;
export type ReactionMessageRepository = Pick<
    MessageRepositoryInterface,
    'findById' | 'upsertReaction' | 'removeReaction'
>;

export interface ReactionServiceDependencies {
    conversationRepository?: ReactionConversationRepository;
    messageRepository?: ReactionMessageRepository;
}

export interface ReactionServiceInterface {
    addOrUpdateReaction: ReactionService['addOrUpdateReaction'];
    removeReaction: ReactionService['removeReaction'];
}
