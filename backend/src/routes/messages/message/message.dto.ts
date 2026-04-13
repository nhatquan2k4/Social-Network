import { Types } from "mongoose";

export interface MessageMediaInput {
    bucket: string;
    objectKey: string;
    mimeType: string;
    size: number;
}

export interface SendDirectMessageInput {
    senderId: Types.ObjectId;
    recipientId: string;
    content?: string;
    conversationId?: string;
    media?: MessageMediaInput[];
}

export interface SendGroupMessageInput {
    senderId: Types.ObjectId;
    conversationId: string;
    content?: string;
    media?: MessageMediaInput[];
}
