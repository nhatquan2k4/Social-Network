import { MEDIA_ERROR_MESSAGES } from './media.constants.js';

export class UnsupportedMediaTypeError extends Error {
    constructor() {
        super(MEDIA_ERROR_MESSAGES.UNSUPPORTED_FILE_TYPE);
    }
}

export class MediaFileTooLargeError extends Error {
    constructor() {
        super(MEDIA_ERROR_MESSAGES.FILE_TOO_LARGE);
    }
}

export class MediaFilesLimitExceededError extends Error {
    constructor() {
        super(MEDIA_ERROR_MESSAGES.TOO_MANY_FILES);
    }
}
