import { Types } from "mongoose";

export interface UpsertReactionInput {
    messageId: string;
    userId: Types.ObjectId;
    emoji: string;
}

export interface RemoveReactionInput {
    messageId: string;
    userId: Types.ObjectId;
}
