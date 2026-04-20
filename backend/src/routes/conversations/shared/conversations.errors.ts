import { CONVERSATION_ERROR_MESSAGES } from "./conversations.constants.js";

export class ConversationTypeInvalidError extends Error {
    constructor() {
        super(CONVERSATION_ERROR_MESSAGES.INVALID_TYPE);
        this.name = "ConversationTypeInvalidError";
    }
}

export class ConversationNotFoundError extends Error {
    constructor() {
        super(CONVERSATION_ERROR_MESSAGES.NOT_FOUND);
        this.name = "ConversationNotFoundError";
    }
}

export class GroupLeaveOnlyError extends Error {
    constructor() {
        super(CONVERSATION_ERROR_MESSAGES.GROUP_ONLY_LEAVE);
        this.name = "GroupLeaveOnlyError";
    }
}

export class GroupMemberNotFoundError extends Error {
    constructor() {
        super(CONVERSATION_ERROR_MESSAGES.NOT_GROUP_MEMBER);
        this.name = "GroupMemberNotFoundError";
    }
}

export class GroupOwnerNotFoundError extends Error {
    constructor() {
        super(CONVERSATION_ERROR_MESSAGES.OWNER_NOT_FOUND);
        this.name = "GroupOwnerNotFoundError";
    }
}
