export const MESSAGE_ERROR_MESSAGES = {
    MISSING_CONTENT_OR_MEDIA: "Thieu noi dung hoac media",
    MISSING_CONVERSATION_ID: "Thieu conversationId",
    CONVERSATION_NOT_FOUND: "Conversation khong ton tai",
    FORBIDDEN_CONVERSATION_ACCESS: "Ban khong co quyen truy cap cuoc tro chuyen nay",
    MESSAGE_NOT_FOUND: "Tin nhan khong ton tai",
    INVALID_EMOJI: "Emoji khong hop le",
    INVALID_MESSAGE_ID: "messageId khong hop le",
    INVALID_IDS: "conversationId hoac messageId khong hop le",
    INVALID_MEDIA: "Thieu media hop le",
} as const;

export const MESSAGE_SUCCESS_MESSAGES = {
    SENT_DIRECT: "Da gui tin nhan truc tiep",
    SENT_DIRECT_MEDIA: "Da gui anh truc tiep",
    SENT_GROUP_MEDIA: "Da gui anh nhom",
    REACTION_UPDATED: "Cap nhat reaction thanh cong",
    REACTION_REMOVED: "Da go reaction tin nhan",
    READ_MARKED: "Da danh dau tin nhan da doc",
    READ_BULK_MARKED: "Da danh dau nhieu tin nhan da doc",
} as const;

export const DEFAULT_REACTION_MAX_LENGTH = 32;
