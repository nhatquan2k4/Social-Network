export class DuplicateUsernameError extends Error {
    constructor() {
        super('Username da ton tai');
    }
}

export class DuplicateEmailError extends Error {
    constructor() {
        super('Email da ton tai');
    }
}

export class InvalidCredentialsError extends Error {
    constructor() {
        super('Sai ten dang nhap hoac mat khau');
    }
}

export class InvalidEmailVerificationTokenError extends Error {
    constructor() {
        super('Token xac thuc khong hop le hoac da het han');
    }
}

export class InvalidEmailError extends Error {
    constructor() {
        super('Vui long cung cap email hop le');
    }
}
