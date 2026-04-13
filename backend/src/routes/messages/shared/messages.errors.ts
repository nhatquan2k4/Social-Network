import { MESSAGE_ERROR_MESSAGES } from "./messages.constants";

export class MessageNotFoundError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.MESSAGE_NOT_FOUND);
        this.name = "MessageNotFoundError";
    }
}

export class ConversationNotFoundError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.CONVERSATION_NOT_FOUND);
        this.name = "ConversationNotFoundError";
    }
}

export class ConversationAccessDeniedError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.FORBIDDEN_CONVERSATION_ACCESS);
        this.name = "ConversationAccessDeniedError";
    }
}

export class MissingContentOrMediaError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.MISSING_CONTENT_OR_MEDIA);
        this.name = "MissingContentOrMediaError";
    }
}

export class MissingConversationIdError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.MISSING_CONVERSATION_ID);
        this.name = "MissingConversationIdError";
    }
}

export class InvalidEmojiError extends Error {
    constructor() {
        super(MESSAGE_ERROR_MESSAGES.INVALID_EMOJI);
        this.name = "InvalidEmojiError";
    }
}
