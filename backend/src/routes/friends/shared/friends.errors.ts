import { FRIEND_ERROR_MESSAGES } from "./friends.constants.js";

export class MissingFriendRecipientError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.MISSING_TO);
        this.name = "MissingFriendRecipientError";
    }
}

export class FriendSelfRequestError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.SELF_REQUEST);
        this.name = "FriendSelfRequestError";
    }
}

export class FriendUserNotFoundError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.USER_NOT_FOUND);
        this.name = "FriendUserNotFoundError";
    }
}

export class AlreadyFriendsError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.ALREADY_FRIENDS);
        this.name = "AlreadyFriendsError";
    }
}

export class FriendRequestPendingError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.REQUEST_PENDING);
        this.name = "FriendRequestPendingError";
    }
}

export class MissingFriendRequestIdError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.REQUEST_ID_MISSING);
        this.name = "MissingFriendRequestIdError";
    }
}

export class FriendRequestNotFoundError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.REQUEST_NOT_FOUND);
        this.name = "FriendRequestNotFoundError";
    }
}

export class FriendRequestAcceptForbiddenError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.FORBIDDEN_ACCEPT_REQUEST);
        this.name = "FriendRequestAcceptForbiddenError";
    }
}

export class FriendRequestRejectForbiddenError extends Error {
    constructor() {
        super(FRIEND_ERROR_MESSAGES.FORBIDDEN_REJECT_REQUEST);
        this.name = "FriendRequestRejectForbiddenError";
    }
}
