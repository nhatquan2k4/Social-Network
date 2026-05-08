import mongoose from "mongoose";

const friendSchema = new mongoose.Schema(
    {
        userA: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        userB: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
    },
    {
        timestamps: true,
    },
);

friendSchema.pre("save", function () {
    const a = this.userA.toString();
    const b = this.userB.toString();

    if (a > b) {
        this.userA = new mongoose.Types.ObjectId(b);
        this.userB = new mongoose.Types.ObjectId(a);
    }
});

friendSchema.index({ userA: 1, userB: 1 }, { unique: true });

const friendRequestSchema = new mongoose.Schema(
    {
        from: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        to: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        message: {
            type: String,
            maxlength: 300,
        },
    },
    { timestamps: true },
);

friendRequestSchema.index({ from: 1, to: 1 }, { unique: true });
friendRequestSchema.index({ from: 1 });
friendRequestSchema.index({ to: 1 });

const userBlockSchema = new mongoose.Schema(
    {
        blockerId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        blockedId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
    },
    { timestamps: true },
);

userBlockSchema.index({ blockerId: 1, blockedId: 1 }, { unique: true });
userBlockSchema.index({ blockedId: 1 });

export const FriendModel =
    mongoose.models.Friend || mongoose.model("Friend", friendSchema);

export const FriendRequestModel =
    mongoose.models.FriendRequest ||
    mongoose.model("FriendRequest", friendRequestSchema);

export const UserBlockModel =
    mongoose.models.UserBlock || mongoose.model("UserBlock", userBlockSchema);
