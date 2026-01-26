import mongoose from "mongoose";

const reactionSchema = new mongoose.Schema(
    {
        postId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Post",
            required: true,
        },
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        reactionType: {
            type: String,
            enum: ["like", "love", "haha", "wow", "sad", "angry"],
            required: true,
        },
    },
    { timestamps: true }
);

// 1 User chỉ được 1 Reaction cho 1 Post
reactionSchema.index({ postId: 1, userId: 1 }, { unique: true });

const Reaction = mongoose.models.Reaction || mongoose.model("Reaction", reactionSchema);
export default Reaction;
