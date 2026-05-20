import { Request, Response, NextFunction } from "express";
import { ReportService } from "./report.service.js";
import type { ReportServiceInterface } from "./report.service.interface.js";
import { POST_SUCCESS_MESSAGES } from "../shared/posts.constants.js";

const reportService: ReportServiceInterface = new ReportService();

export const reportPost = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { postId } = req.params;
        const userId = req.user!._id;
        const { reason, description } = req.body;

        const result = await reportService.reportPost(
            postId as string,
            userId,
            reason,
            description,
        );

        return res.status(201).json({
            message: POST_SUCCESS_MESSAGES.REPORT_CREATED,
            data: result,
        });
    } catch (error) {
        next(error);
    }
};
