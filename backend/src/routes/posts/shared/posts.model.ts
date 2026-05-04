import mongoose from "mongoose";

const postMediaSchema = new mongoose.Schema(
    {
        bucket: {
            type: String,
            required: true,
            trim: true,
        },
        objectKey: {
            type: String,
            required: true,
            trim: true,
        },
        mimeType: {
            type: String,
            required: true,
            trim: true,
        },
        size: {
            type: Number,
            required: true,
        },
    },
    {
        _id: false,
    },
);

const postCommentSchema = new mongoose.Schema(
    {
        parentCommentId: {
            type: mongoose.Schema.Types.ObjectId,
            default: null,
        },
        authorId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        content: {
            type: String,
            required: true,
            trim: true,
            maxlength: 1500,
        },
        createdAt: {
            type: Date,
            default: Date.now,
        },
        updatedAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        _id: true,
    },
);

const postSchema = new mongoose.Schema(
    {
        authorId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            index: true,
        },
        content: {
            type: String,
            trim: true,
            maxlength: 3000,
        },
        media: {
            type: [postMediaSchema],
            default: [],
        },
        likes: {
            type: [mongoose.Schema.Types.ObjectId],
            ref: "User",
            default: [],
        },
        comments: {
            type: [postCommentSchema],
            default: [],
        },
        commentsCount: {
            type: Number,
            default: 0,
        },
        isHidden: {
            type: Boolean,
            default: false,
            index: true,
        },
        hiddenAt: {
            type: Date,
            default: null,
        },
        hiddenReason: {
            type: String,
            trim: true,
            maxlength: 500,
        },
    },
    {
        timestamps: true,
    },
);

postSchema.index({ createdAt: -1 });

export const PostModel =
    mongoose.models.Post || mongoose.model("Post", postSchema);
