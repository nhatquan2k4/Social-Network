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
} as const;

export const FRIEND_SUCCESS_MESSAGES = {
    REQUEST_SENT: "Da gui loi moi ket ban",
    REQUEST_ACCEPTED: "Da chap nhan loi moi ket ban",
    REQUEST_REJECTED: "Da tu choi loi moi ket ban",
} as const;
