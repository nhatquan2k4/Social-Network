import { Types } from "mongoose";
import { PostRepository } from "../shared/posts.repo.js";
import { ReportRepository } from "../shared/reports.repo.js";
import {
    POST_ERROR_MESSAGES,
    REPORT_REASONS,
    ReportReason,
} from "../shared/posts.constants.js";
import { AppError } from "../../../shared/errors/app-error.js";

/** Số report tối thiểu để tự động ẩn post */
const AUTO_HIDE_THRESHOLD = 5;

import type {
    ReportPostReportRepository,
    ReportPostRepository,
    ReportServiceDependencies,
    ReportServiceInterface,
} from "./report.service.interface.js";

export class ReportService implements ReportServiceInterface {
    private postRepo: ReportPostRepository;
    private reportRepo: ReportPostReportRepository;

    constructor(dependencies: ReportServiceDependencies = {}) {
        this.postRepo = dependencies.postRepository ?? new PostRepository();
        this.reportRepo = dependencies.reportRepository ?? new ReportRepository();
    }

    async reportPost(
        postId: string,
        reporterId: Types.ObjectId,
        reason: unknown,
        description: unknown,
    ) {
        // Validate reason
        if (!reason || typeof reason !== "string") {
            throw new AppError(POST_ERROR_MESSAGES.REPORT_REASON_REQUIRED, 400);
        }

        if (!REPORT_REASONS.includes(reason as ReportReason)) {
            throw new AppError(
                POST_ERROR_MESSAGES.REPORT_REASON_INVALID,
                400,
                { validReasons: REPORT_REASONS },
            );
        }

        // Check post ton tai
        const post = await this.postRepo.findRawById(postId);
        if (!post) {
            throw new AppError(POST_ERROR_MESSAGES.POST_NOT_FOUND, 404);
        }

        // Khong cho report bai cua chinh minh
        if (post.authorId.toString() === reporterId.toString()) {
            throw new AppError(POST_ERROR_MESSAGES.REPORT_OWN_POST, 400);
        }

        // Check duplicate report
        const existing = await this.reportRepo.findByPostAndReporter(
            new Types.ObjectId(postId),
            reporterId,
        );
        if (existing) {
            throw new AppError(POST_ERROR_MESSAGES.REPORT_DUPLICATE, 409);
        }

        // Normalize description
        const safeDescription =
            typeof description === "string" ? description.trim().slice(0, 1000) : undefined;

        const report = await this.reportRepo.create({
            postId: new Types.ObjectId(postId),
            reporterId,
            reason: reason as string,
            description: safeDescription,
        });

        const reportCount = await this.reportRepo.countByPostId(
            new Types.ObjectId(postId),
        );

        // Auto-hide khi đạt ngưỡng
        let autoHidden = false;
        if (reportCount >= AUTO_HIDE_THRESHOLD && !(post as any).isHidden) {
            await this.postRepo.hidePost(
                postId,
                `Tu dong an: ${reportCount} reports`,
            );
            autoHidden = true;
        }

        return {
            reportId: report._id,
            postId,
            reason,
            description: safeDescription ?? null,
            reportCount,
            autoHidden,
            createdAt: (report as any).createdAt,
        };
    }
}
