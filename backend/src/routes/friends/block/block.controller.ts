import { Request, Response } from "express";
import {
    FRIEND_ERROR_MESSAGES,
    FRIEND_SUCCESS_MESSAGES,
} from "../shared/friends.constants.js";
import {
    FriendSelfBlockError,
    FriendUserNotFoundError,
    MissingBlockUserError,
} from "../shared/friends.errors.js";
import { BlockService } from "./block.service.js";

const blockService = new BlockService();

export const blockUser = async (req: Request, res: Response) => {
    try {
        const blockerId = req.user!._id;
        const { userId } = req.body;

        const block = await blockService.blockUser(blockerId, userId);

        return res.status(201).json({
            message: FRIEND_SUCCESS_MESSAGES.BLOCK_CREATED,
            data: block,
        });
    } catch (error: any) {
        console.error("Loi khi block nguoi dung", error);
        if (error?.name === "CastError") {
            return res.status(400).json({ message: FRIEND_ERROR_MESSAGES.MISSING_BLOCK_USER });
        }
        if (error instanceof MissingBlockUserError || error instanceof FriendSelfBlockError) {
            return res.status(400).json({ message: error.message });
        }
        if (error instanceof FriendUserNotFoundError) {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const unblockUser = async (req: Request, res: Response) => {
    try {
        const blockerId = req.user!._id;
        const { userId } = req.params;

        await blockService.unblockUser(blockerId, userId as string);

        return res.status(200).json({
            message: FRIEND_SUCCESS_MESSAGES.BLOCK_REMOVED,
        });
    } catch (error: any) {
        console.error("Loi khi bo block nguoi dung", error);
        if (error?.name === "CastError" || error instanceof MissingBlockUserError) {
            return res.status(400).json({ message: FRIEND_ERROR_MESSAGES.MISSING_BLOCK_USER });
        }
        return res.status(500).json({ message: "Loi server" });
    }
};

export const getBlockedUsers = async (req: Request, res: Response) => {
    try {
        const blockerId = req.user!._id;
        const data = await blockService.getBlockedUsers(blockerId);

        return res.status(200).json({ data });
    } catch (error) {
        console.error("Loi khi lay danh sach block", error);
        return res.status(500).json({ message: "Loi server" });
    }
};

