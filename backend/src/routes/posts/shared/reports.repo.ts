import { Types } from "mongoose";
import { ReportModel as Report } from "./reports.model.js";

export class ReportRepository {
    async create(data: {
        postId: Types.ObjectId;
        reporterId: Types.ObjectId;
        reason: string;
        description?: string;
    }) {
        return Report.create(data);
    }

    async findByPostAndReporter(postId: Types.ObjectId, reporterId: Types.ObjectId) {
        return Report.findOne({ postId, reporterId });
    }

    async countByPostId(postId: Types.ObjectId) {
        return Report.countDocuments({ postId });
    }

    async findByPostId(postId: Types.ObjectId) {
        return Report.find({ postId })
            .populate("reporterId", "username displayName avatarUrl")
            .sort({ createdAt: -1 })
            .lean();
    }

    async findPending(skip: number, limit: number) {
        const [items, total] = await Promise.all([
            Report.find({ status: "pending" })
                .populate("postId")
                .populate("reporterId", "username displayName avatarUrl")
                .sort({ createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .lean(),
            Report.countDocuments({ status: "pending" }),
        ]);

        return { items, total };
    }

    async updateStatus(
        reportId: string,
        status: string,
        reviewedBy: Types.ObjectId,
        reviewNote?: string,
    ) {
        return Report.findByIdAndUpdate(
            reportId,
            {
                $set: {
                    status,
                    reviewedBy,
                    reviewedAt: new Date(),
                    ...(reviewNote ? { reviewNote } : {}),
                },
            },
            { new: true },
        );
    }
}
