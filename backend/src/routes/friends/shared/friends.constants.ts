export const FRIEND_ERROR_MESSAGES = {
    MISSING_TO: "Thieu to",
    SELF_REQUEST: "Khong the gui loi moi ket ban voi chinh ban than",
    USER_NOT_FOUND: "Nguoi dung khong ton tai",
    ALREADY_FRIENDS: "Hai nguoi da la ban be",
    REQUEST_PENDING: "Da co loi moi ket ban dang cho duyet",
    REQUEST_ID_MISSING: "Thieu requestId",
    REQUEST_NOT_FOUND: "Khong tim thay loi moi ket ban",
    FORBIDDEN_ACCEPT_REQUEST: "Khong co quyen chap nhan loi moi ket ban",
    FORBIDDEN_REJECT_REQUEST: "Khong co quyen tu choi loi moi ket ban",
    MISSING_BLOCK_USER: "Thieu userId can block",
    SELF_BLOCK: "Khong the block chinh minh",
    BLOCKED_INTERACTION: "Khong the thuc hien hanh dong nay vi da co quan he block",
} as const;

export const FRIEND_SUCCESS_MESSAGES = {
    REQUEST_SENT: "Da gui loi moi ket ban",
    REQUEST_ACCEPTED: "Da chap nhan loi moi ket ban",
    REQUEST_REJECTED: "Da tu choi loi moi ket ban",
    BLOCK_CREATED: "Da block nguoi dung",
    BLOCK_REMOVED: "Da bo block nguoi dung",
} as const;
