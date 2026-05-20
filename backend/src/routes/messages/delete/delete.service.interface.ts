import type { ConversationRepositoryInterface } from '../../conversations/shared/conversations.repo.interface.js';
import type { MessageRepositoryInterface } from '../shared/messages.repo.interface.js';
import type { DeleteMessageService } from './delete.service.js';

export type DeleteMessageConversationRepository = Pick<
    ConversationRepositoryInterface,
    'findById'
>;
export type DeleteMessageRepository = Pick<
    MessageRepositoryInterface,
    | 'findByIdAndConversationId'
    | 'deleteByIdAndConversationId'
    | 'findLatestByConversationId'
>;

export interface DeleteMessageServiceDependencies {
    conversationRepository?: DeleteMessageConversationRepository;
    messageRepository?: DeleteMessageRepository;
}

export interface DeleteMessageServiceInterface {
    deleteForEveryone: DeleteMessageService['deleteForEveryone'];
}
