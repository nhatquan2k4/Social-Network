import { Request, Response } from "express";
import {
    POST_ERROR_MESSAGES,
    POST_SUCCESS_MESSAGES,
} from "../shared/posts.constants";
import { CommentService } from "./comment.service";

const commentService = new CommentService();

export const createPostComment = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const { content, parentCommentId } = req.body;
        const userId = req.user!._id;

        const comment = await commentService.addComment(
            postId as string,
            userId,
            content,
            parentCommentId,
        );

        return res.status(201).json({
            message: POST_SUCCESS_MESSAGES.COMMENT_CREATED,
            data: comment,
        });
    } catch (error: any) {
        console.error("Loi khi tao comment", error);
        if (error.message === POST_ERROR_MESSAGES.COMMENT_EMPTY) {
            return res.status(400).json({ message: error.message });
        }
        if (
            error.message === POST_ERROR_MESSAGES.PARENT_COMMENT_NOT_FOUND ||
            error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND
        ) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const getPostComments = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const result = await commentService.getComments(postId as string);

        return res.status(200).json({ data: result });
    } catch (error: any) {
        console.error("Loi khi lay comment", error);
        if (error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const deletePostComment = async (req: Request, res: Response) => {
    try {
        const { postId, commentId } = req.params;
        const userId = req.user!._id;

        await commentService.deleteComment(postId as string, commentId as string, userId);

        return res.status(200).json({ message: POST_SUCCESS_MESSAGES.COMMENT_DELETED });
    } catch (error: any) {
        console.error("Loi khi xoa comment", error);
        if (
            error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND ||
            error.message === POST_ERROR_MESSAGES.COMMENT_NOT_FOUND
        ) {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === POST_ERROR_MESSAGES.COMMENT_DELETE_FORBIDDEN) {
            return res.status(403).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
