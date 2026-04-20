import { PostMediaInput } from "../shared/posts.repo.js";

export interface UpdatePostPayload {
    content?: string;
    hasContentField: boolean;
    mediaFromBody?: PostMediaInput[];
    hasMediaField: boolean;
    uploadedMedia?: PostMediaInput[];
}
