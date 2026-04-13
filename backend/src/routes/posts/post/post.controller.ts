import { Request, Response } from "express";
import { MediaService } from "../../media/upload/upload.service";
import {
    POST_ERROR_MESSAGES,
    POST_SUCCESS_MESSAGES,
} from "../shared/posts.constants";
import {
    normalizeUploadedMedia,
    parseManualMedia,
} from "../shared/posts.util";
import { PostService } from "./post.service";

const postService = new PostService();
const mediaService = new MediaService();

export const createPost = async (req: Request, res: Response) => {
    try {
        const authorId = req.user!._id;
        const { content, media } = req.body;

        const files = (req.files || []) as Express.Multer.File[];
        const uploadedMedia =
            files.length > 0
                ? await mediaService.uploadFiles(files, "post", authorId.toString())
                : [];

        const mergedMedia = [
            ...parseManualMedia(media),
            ...normalizeUploadedMedia(uploadedMedia),
        ];

        const post = await postService.createPost(authorId, content, mergedMedia);

        return res.status(201).json({
            message: POST_SUCCESS_MESSAGES.CREATED,
            data: post,
        });
    } catch (error: any) {
        console.error("Loi khi tao post", error);
        if (error.message === POST_ERROR_MESSAGES.REQUIRE_CONTENT_OR_MEDIA) {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const getPostById = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const post = await postService.getPostById(postId as string);

        return res.status(200).json({ data: post });
    } catch (error: any) {
        console.error("Loi khi lay post", error);
        if (error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const updatePost = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const userId = req.user!._id;
        const hasContentField = Object.prototype.hasOwnProperty.call(req.body || {}, "content");
        const hasMediaField = Object.prototype.hasOwnProperty.call(req.body || {}, "media");
        const { content, media } = req.body;
        const files = (req.files || []) as Express.Multer.File[];

        if (!hasContentField && !hasMediaField && files.length === 0) {
            return res.status(400).json({ message: POST_ERROR_MESSAGES.UPDATE_DATA_MISSING });
        }

        if (hasMediaField && typeof media === "string") {
            try {
                JSON.parse(media);
            } catch {
                return res.status(400).json({ message: POST_ERROR_MESSAGES.MEDIA_JSON_INVALID });
            }
        }

        const uploadedMedia =
            files.length > 0
                ? await mediaService.uploadFiles(files, "post", userId.toString())
                : [];

        const normalizedUploaded = normalizeUploadedMedia(uploadedMedia);
        const manualMedia = hasMediaField ? parseManualMedia(media) : [];

        const updatedPost = await postService.updatePost(postId as string, userId, {
            content,
            hasContentField,
            mediaFromBody: hasMediaField ? manualMedia : undefined,
            hasMediaField,
            uploadedMedia: normalizedUploaded,
        });

        return res.status(200).json({
            message: POST_SUCCESS_MESSAGES.UPDATED,
            data: updatedPost,
        });
    } catch (error: any) {
        console.error("Loi khi chinh sua post", error);
        if (
            error.message === POST_ERROR_MESSAGES.UPDATE_DATA_MISSING ||
            error.message === POST_ERROR_MESSAGES.REQUIRE_CONTENT_OR_MEDIA
        ) {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND) {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === POST_ERROR_MESSAGES.UPDATE_FORBIDDEN) {
            return res.status(403).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const deletePost = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const userId = req.user!._id;

        await postService.deletePost(postId as string, userId);

        return res.status(200).json({ message: POST_SUCCESS_MESSAGES.DELETED });
    } catch (error: any) {
        console.error("Loi khi xoa post", error);
        if (error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND) {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === POST_ERROR_MESSAGES.DELETE_FORBIDDEN) {
            return res.status(403).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
