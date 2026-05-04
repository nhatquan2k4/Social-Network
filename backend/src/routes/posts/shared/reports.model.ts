import mongoose from "mongoose";

const reportSchema = new mongoose.Schema(
    {
        postId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Post",
            required: true,
            index: true,
        },
        reporterId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true,
        },
        reason: {
            type: String,
            required: true,
            enum: [
                "spam",
                "harassment",
                "hate_speech",
                "violence",
                "nudity",
                "false_information",
                "other",
            ],
        },
        description: {
            type: String,
            trim: true,
            maxlength: 1000,
        },
        status: {
            type: String,
            enum: ["pending", "reviewed", "resolved", "dismissed"],
            default: "pending",
            index: true,
        },
        reviewedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            default: null,
        },
        reviewedAt: {
            type: Date,
            default: null,
        },
        reviewNote: {
            type: String,
            trim: true,
            maxlength: 1000,
        },
    },
    {
        timestamps: true,
    },
);

// Mỗi user chỉ report 1 post 1 lần
reportSchema.index({ postId: 1, reporterId: 1 }, { unique: true });

export const ReportModel =
    mongoose.models.Report || mongoose.model("Report", reportSchema);
