export interface CreateConversationRequest {
    type: string;
    name?: string;
    memberIds?: string[];
    recipientId?: string;
}

export interface GetConversationsQuery {
    recipientId?: string;
}
