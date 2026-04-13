import { POST_ERROR_MESSAGES } from "./posts.constants";

export class PostNotFoundError extends Error {
    constructor() {
        super(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        this.name = "PostNotFoundError";
    }
}
