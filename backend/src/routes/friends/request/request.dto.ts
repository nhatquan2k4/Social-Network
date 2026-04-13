import { Types } from "mongoose";

export interface SendFriendRequestInput {
    from: Types.ObjectId;
    to: string;
    message?: string;
}

export interface HandleFriendRequestInput {
    requestId: string;
    userId: Types.ObjectId;
}
