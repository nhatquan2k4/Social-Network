import { Request, Response } from "express";
import {
    POST_ERROR_MESSAGES,
    POST_SUCCESS_MESSAGES,
} from "../shared/posts.constants.js";
import { LikeService } from "./like.service.js";
import type { LikeServiceInterface } from "./like.service.interface.js";

const likeService: LikeServiceInterface = new LikeService();

export const toggleLikePost = async (req: Request, res: Response) => {
    try {
        const { postId } = req.params;
        const userId = req.user!._id;

        const post = await likeService.toggleLike(postId as string, userId);

        return res.status(200).json({
            message: POST_SUCCESS_MESSAGES.LIKE_UPDATED,
            data: post,
        });
    } catch (error: any) {
        console.error("Loi khi like/unlike post", error);
        if (error.message === POST_ERROR_MESSAGES.POST_NOT_FOUND) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};
