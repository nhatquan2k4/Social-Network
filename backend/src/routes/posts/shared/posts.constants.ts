export const POST_ERROR_MESSAGES = {
    REQUIRE_CONTENT_OR_MEDIA: "Post phai co content hoac media",
    UPDATE_DATA_MISSING: "Khong co du lieu cap nhat",
    POST_NOT_FOUND: "Post khong ton tai",
    UPDATE_FORBIDDEN: "Khong co quyen chinh sua post nay",
    DELETE_FORBIDDEN: "Khong co quyen xoa post nay",
    COMMENT_EMPTY: "Noi dung comment khong duoc de trong",
    PARENT_COMMENT_NOT_FOUND: "Comment cha khong ton tai",
    COMMENT_NOT_FOUND: "Comment khong ton tai",
    COMMENT_DELETE_FORBIDDEN: "Khong co quyen xoa comment nay",
    MEDIA_JSON_INVALID: "Media JSON khong hop le",
} as const;

export const POST_SUCCESS_MESSAGES = {
    CREATED: "Tao post thanh cong",
    UPDATED: "Chinh sua post thanh cong",
    DELETED: "Xoa post thanh cong",
    LIKE_UPDATED: "Cap nhat like thanh cong",
    COMMENT_CREATED: "Tao comment thanh cong",
    COMMENT_DELETED: "Xoa comment thanh cong",
} as const;
