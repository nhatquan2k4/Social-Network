export const CONVERSATION_TYPES = {
    DIRECT: "direct",
    GROUP: "group",
} as const;

export const DEFAULT_MESSAGES_LIMIT = 50;

export const CONVERSATION_ERROR_MESSAGES = {
    INVALID_TYPE: "Conversation type khong hop le",
    NOT_FOUND: "Conversation khong ton tai",
    GROUP_ONLY_LEAVE: "Chi ho tro roi nhom cho group conversation",
    NOT_GROUP_MEMBER: "Ban khong o trong group nay",
    OWNER_NOT_FOUND: "Khong tim thay owner moi",
} as const;
