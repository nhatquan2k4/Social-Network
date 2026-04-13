import { Types } from "mongoose";

export interface MarkReadInput {
    conversationId: string;
    messageId: string;
    userId: Types.ObjectId;
}

export interface MarkBulkReadInput {
    conversationId: string;
    userId: Types.ObjectId;
    lastMessageId?: string;
}
