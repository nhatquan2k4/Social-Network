import mongoose from "mongoose";

const postSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            trim: true,
            lowercase: true,
            index: true,
            ref: "User",
        },
        content: {
            type: String,
            required: true,
            trim: true,
            maxlength: 2000,
        },
        media: {
            type: [String],
            default: [],
        },
        privacy: {
            type: String,
            enum: ["public", "friends", "private"],
            default: "public",
            index: true,
        },
        reactions: {
            type: Map,
            of: Number,
            default: {},
        },
        commentsCount: {
            type: Number,
            default: 0,
        },
        sharesCount: {
            type: Number,
            default: 0,
        },
    },
    {
        timestamps: true,
    },
);
const Post = mongoose.model("Post", postSchema);
export default Post;
