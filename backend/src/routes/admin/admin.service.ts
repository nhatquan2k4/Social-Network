import { Types } from "mongoose";
import { PostRepository } from "../posts/shared/posts.repo.js";
import { ReportRepository } from "../posts/shared/reports.repo.js";
import { AppError } from "../../shared/errors/app-error.js";

export class AdminService {
    private postRepo: PostRepository;
    private reportRepo: ReportRepository;

    constructor() {
        this.postRepo = new PostRepository();
        this.reportRepo = new ReportRepository();
    }

    /**
     * Lấy danh sách reports đang pending, có phân trang.
     */
    async getPendingReports(page: number, limit: number) {
        const safePage = Math.max(1, page);
        const safeLimit = Math.max(1, Math.min(limit, 50));
        const skip = (safePage - 1) * safeLimit;

        const { items, total } = await this.reportRepo.findPending(skip, safeLimit);

        return {
            items,
            page: safePage,
            limit: safeLimit,
            total,
            totalPages: Math.ceil(total / safeLimit),
            hasMore: skip + items.length < total,
        };
    }

    /**
     * Lấy tất cả reports của 1 post cụ thể.
     */
    async getReportsByPost(postId: string) {
        const post = await this.postRepo.findRawById(postId);
        if (!post) {
            throw new AppError("Post khong ton tai", 404);
        }

        const reports = await this.reportRepo.findByPostId(
            new Types.ObjectId(postId),
        );
        const reportCount = await this.reportRepo.countByPostId(
            new Types.ObjectId(postId),
        );

        return {
            postId,
            isHidden: (post as any).isHidden ?? false,
            reportCount,
            reports,
        };
    }

    /**
     * Admin ẩn post (hide) + đánh dấu các reports liên quan là "resolved".
     */
    async hidePost(postId: string, adminId: Types.ObjectId, reviewNote?: string) {
        const post = await this.postRepo.findRawById(postId);
        if (!post) {
            throw new AppError("Post khong ton tai", 404);
        }

        const reason = reviewNote || "An boi admin";
        await this.postRepo.hidePost(postId, reason);

        // Đánh dấu tất cả pending reports của post này là "resolved"
        await this.resolveAllReportsForPost(postId, adminId, "resolved", reviewNote);

        return { postId, action: "hidden", reason };
    }

    /**
     * Admin restore (unhide) post + đánh dấu reports là "dismissed".
     */
    async restorePost(postId: string, adminId: Types.ObjectId, reviewNote?: string) {
        const post = await this.postRepo.findRawById(postId);
        if (!post) {
            throw new AppError("Post khong ton tai", 404);
        }

        await this.postRepo.unhidePost(postId);

        // Đánh dấu tất cả pending reports của post này là "dismissed"
        await this.resolveAllReportsForPost(postId, adminId, "dismissed", reviewNote);

        return { postId, action: "restored" };
    }

    /**
     * Admin xóa hẳn post + resolve reports.
     */
    async deletePost(postId: string, adminId: Types.ObjectId, reviewNote?: string) {
        const post = await this.postRepo.findRawById(postId);
        if (!post) {
            throw new AppError("Post khong ton tai", 404);
        }

        // Resolve tất cả reports trước khi xóa
        await this.resolveAllReportsForPost(postId, adminId, "resolved", reviewNote || "Post da bi xoa");

        await this.postRepo.deleteById(postId);

        return { postId, action: "deleted" };
    }

    /**
     * Admin review 1 report cụ thể — chuyển status sang resolved/dismissed.
     */
    async reviewReport(
        reportId: string,
        adminId: Types.ObjectId,
        status: "resolved" | "dismissed",
        reviewNote?: string,
    ) {
        const report = await this.reportRepo.updateStatus(
            reportId,
            status,
            adminId,
            reviewNote,
        );

        if (!report) {
            throw new AppError("Report khong ton tai", 404);
        }

        return report;
    }

    // ── Private helpers ──

    private async resolveAllReportsForPost(
        postId: string,
        adminId: Types.ObjectId,
        status: string,
        reviewNote?: string,
    ) {
        const reports = await this.reportRepo.findByPostId(
            new Types.ObjectId(postId),
        );

        const pendingReports = reports.filter((r: any) => r.status === "pending");

        await Promise.all(
            pendingReports.map((r: any) =>
                this.reportRepo.updateStatus(
                    r._id.toString(),
                    status,
                    adminId,
                    reviewNote,
                ),
            ),
        );
    }
}
