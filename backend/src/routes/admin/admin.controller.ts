import { Request, Response, NextFunction } from "express";
import { AdminService } from "./admin.service.js";
import type { AdminServiceInterface } from "./admin.service.interface.js";
import { AppError } from "../../shared/errors/app-error.js";

const adminService: AdminServiceInterface = new AdminService();

/** GET /api/admin/reports — Danh sách reports pending */
export const getPendingReports = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const page = Number(req.query.page || "1");
        const limit = Number(req.query.limit || "20");

        const result = await adminService.getPendingReports(page, limit);
        return res.status(200).json({ data: result });
    } catch (error) {
        next(error);
    }
};

/** GET /api/admin/reports/post/:postId — Reports của 1 post */
export const getReportsByPost = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { postId } = req.params;
        const result = await adminService.getReportsByPost(postId as string);
        return res.status(200).json({ data: result });
    } catch (error) {
        next(error);
    }
};

/** PATCH /api/admin/posts/:postId/hide — Ẩn post */
export const hidePost = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { postId } = req.params;
        const adminId = req.user!._id;
        const { reviewNote } = req.body;

        const result = await adminService.hidePost(
            postId as string,
            adminId,
            typeof reviewNote === "string" ? reviewNote.trim() : undefined,
        );
        return res.status(200).json({ message: "An post thanh cong", data: result });
    } catch (error) {
        next(error);
    }
};

/** PATCH /api/admin/posts/:postId/restore — Restore post bị ẩn */
export const restorePost = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { postId } = req.params;
        const adminId = req.user!._id;
        const { reviewNote } = req.body;

        const result = await adminService.restorePost(
            postId as string,
            adminId,
            typeof reviewNote === "string" ? reviewNote.trim() : undefined,
        );
        return res.status(200).json({ message: "Restore post thanh cong", data: result });
    } catch (error) {
        next(error);
    }
};

/** DELETE /api/admin/posts/:postId — Xóa hẳn post */
export const deletePost = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { postId } = req.params;
        const adminId = req.user!._id;
        const reviewNote =
            typeof req.body.reviewNote === "string"
                ? req.body.reviewNote.trim()
                : undefined;

        const result = await adminService.deletePost(
            postId as string,
            adminId,
            reviewNote,
        );
        return res.status(200).json({ message: "Xoa post thanh cong", data: result });
    } catch (error) {
        next(error);
    }
};

/** PATCH /api/admin/reports/:reportId — Review 1 report */
export const reviewReport = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { reportId } = req.params;
        const adminId = req.user!._id;
        const { status, reviewNote } = req.body;

        if (!status || !["resolved", "dismissed"].includes(status)) {
            throw new AppError(
                "status phai la 'resolved' hoac 'dismissed'",
                400,
            );
        }

        const result = await adminService.reviewReport(
            reportId as string,
            adminId,
            status,
            typeof reviewNote === "string" ? reviewNote.trim() : undefined,
        );
        return res.status(200).json({ message: "Review report thanh cong", data: result });
    } catch (error) {
        next(error);
    }
};
