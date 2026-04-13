export class InvalidUserIdError extends Error {
    constructor() {
        super('userId khong hop le');
    }
}

export class UserNotFoundError extends Error {
    constructor() {
        super('Nguoi dung khong ton tai');
    }
}

export class EmptyUpdatePayloadError extends Error {
    constructor() {
        super('Khong co du lieu cap nhat');
    }
}

export class EmptyDisplayNameError extends Error {
    constructor() {
        super('DisplayName khong duoc de trong');
    }
}
