import { Types } from "mongoose";
import { PostRepository, PostMediaInput } from "../shared/posts.repo.js";
import { POST_ERROR_MESSAGES } from "../shared/posts.constants.js";
import { formatPost } from "../shared/posts.util.js";
import { UpdatePostPayload } from "./post.dto.js";
import type {
    PostServiceDependencies,
    PostServiceInterface,
    PostServicePostRepository,
} from "./post.service.interface.js";

export class PostService implements PostServiceInterface {
    private postRepository: PostServicePostRepository;

    constructor(dependencies: PostServiceDependencies = {}) {
        this.postRepository = dependencies.postRepository ?? new PostRepository();
    }

    async createPost(authorId: Types.ObjectId, content?: string, media?: PostMediaInput[]) {
        if (!content && (!media || media.length === 0)) {
            throw new Error(POST_ERROR_MESSAGES.REQUIRE_CONTENT_OR_MEDIA);
        }

        const safeMedia = (media || []).map((item) => ({
            bucket: item.bucket,
            objectKey: item.objectKey,
            mimeType: item.mimeType,
            size: item.size,
        }));

        const post = await this.postRepository.create({
            authorId,
            content,
            media: safeMedia,
        });

        const populated = await this.postRepository.findById(post._id.toString());
        return formatPost(populated as any);
    }

    async getPostById(postId: string) {
        const post = await this.postRepository.findById(postId);
        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        return formatPost(post as any);
    }

    async updatePost(postId: string, requesterId: Types.ObjectId, payload: UpdatePostPayload) {
        const safeUploaded = (payload.uploadedMedia || []).map((item) => ({
            bucket: item.bucket,
            objectKey: item.objectKey,
            mimeType: item.mimeType,
            size: item.size,
        }));

        if (!payload.hasContentField && !payload.hasMediaField && safeUploaded.length === 0) {
            throw new Error(POST_ERROR_MESSAGES.UPDATE_DATA_MISSING);
        }

        const post = await this.postRepository.findRawById(postId);
        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        if (post.authorId.toString() !== requesterId.toString()) {
            throw new Error(POST_ERROR_MESSAGES.UPDATE_FORBIDDEN);
        }

        const currentContent = typeof post.content === "string" ? post.content : "";
        const currentMedia = (post.media || []).map((item: any) => ({
            bucket: item.bucket,
            objectKey: item.objectKey,
            mimeType: item.mimeType,
            size: item.size,
        }));

        const nextContent = payload.hasContentField ? String(payload.content || "").trim() : currentContent;
        const baseMedia = payload.hasMediaField
            ? (payload.mediaFromBody || []).map((item) => ({
                bucket: item.bucket,
                objectKey: item.objectKey,
                mimeType: item.mimeType,
                size: item.size,
            }))
            : currentMedia;

        const nextMedia = [...baseMedia, ...safeUploaded];

        if (!nextContent && nextMedia.length === 0) {
            throw new Error(POST_ERROR_MESSAGES.REQUIRE_CONTENT_OR_MEDIA);
        }

        post.content = nextContent || undefined;
        post.media = nextMedia as any;

        await this.postRepository.save(post);

        const updated = await this.postRepository.findById(postId);
        if (!updated) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        return formatPost(updated as any);
    }

    async deletePost(postId: string, requesterId: Types.ObjectId) {
        const post = await this.postRepository.findById(postId);

        if (!post) {
            throw new Error(POST_ERROR_MESSAGES.POST_NOT_FOUND);
        }

        if (post.authorId._id.toString() !== requesterId.toString()) {
            throw new Error(POST_ERROR_MESSAGES.DELETE_FORBIDDEN);
        }

        await this.postRepository.deleteById(postId);
    }
}
