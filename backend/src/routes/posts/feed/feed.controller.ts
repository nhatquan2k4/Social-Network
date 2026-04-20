import { Request, Response } from "express";
import { FeedService } from "./feed.service.js";

const feedService = new FeedService();

export const getFeed = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const page = Number(req.query.page || "1");
        const limit = Number(req.query.limit || "20");

        const feed = await feedService.getFeed(userId, page, limit);
        return res.status(200).json({ data: feed });
    } catch (error) {
        console.error("Loi khi lay feed", error);
        return res.status(500).json({ message: "Loi server" });
    }
};
