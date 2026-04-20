import { Request, Response } from "express";
import { FriendService } from "./friend.service.js";

const friendService = new FriendService();

export const getAllFriend = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const friends = await friendService.getAllFriends(userId);

        return res.status(200).json({ friends });
    } catch (error) {
        console.error("Loi khi lay danh sach ban be", error);
        return res.status(500).json({ message: "Loi server" });
    }
};
