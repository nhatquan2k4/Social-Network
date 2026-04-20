import { Types } from "mongoose";
import {
    DEFAULT_MESSAGE_HISTORY_LIMIT,
    MAX_MESSAGE_HISTORY_LIMIT,
    MESSAGE_ERROR_MESSAGES,
} from "../shared/messages.constants";
import { InvalidCursorError } from "../shared/messages.errors";

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

export interface MessageHistoryCursor {
    createdAt: string;
    id: string;
}

export interface MessageHistoryCursorDecoded {
    createdAt: Date;
    id: Types.ObjectId;
}

export interface GetConversationMessagesInput {
    conversationId: string;
    limit: number;
    cursor?: MessageHistoryCursorDecoded;
}

const asSingleString = (value: unknown): string | undefined => {
    if (typeof value === "string") {
        return value;
    }

    if (Array.isArray(value) && typeof value[0] === "string") {
        return value[0];
    }

    return undefined;
};

export const parseMessageHistoryLimit = (rawLimit: unknown): number => {
    const value = asSingleString(rawLimit);
    if (!value || !value.trim()) {
        return DEFAULT_MESSAGE_HISTORY_LIMIT;
    }

    const parsed = Number(value);
    if (!Number.isInteger(parsed) || parsed <= 0 || parsed > MAX_MESSAGE_HISTORY_LIMIT) {
        throw new Error(MESSAGE_ERROR_MESSAGES.INVALID_LIMIT);
    }

    return parsed;
};

export const encodeMessageHistoryCursor = (createdAt: Date, id: Types.ObjectId) => {
    const payload: MessageHistoryCursor = {
        createdAt: createdAt.toISOString(),
        id: id.toString(),
    };

    return Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
};

export const decodeMessageHistoryCursor = (
    rawCursor: unknown,
): MessageHistoryCursorDecoded | undefined => {
    const cursor = asSingleString(rawCursor);
    if (!cursor || !cursor.trim()) {
        return undefined;
    }

    try {
        const decodedRaw = Buffer.from(cursor, "base64url").toString("utf8");
        const parsed = JSON.parse(decodedRaw) as MessageHistoryCursor;
        const createdAt = new Date(parsed.createdAt);

        if (!Number.isFinite(createdAt.getTime())) {
            throw new InvalidCursorError();
        }

        if (!Types.ObjectId.isValid(parsed.id)) {
            throw new InvalidCursorError();
        }

        return {
            createdAt,
            id: new Types.ObjectId(parsed.id),
        };
    } catch {
        throw new InvalidCursorError();
    }
};
