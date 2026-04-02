import mongoose from "mongoose";
export { UserModel } from "../users/users.model";

const sessionSchema = new mongoose.Schema(
	{
		userId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
			required: true,
			index: true,
		},
		refreshToken: {
			type: String,
			required: true,
			unique: true,
		},
		exportedAt: {
			type: Date,
			required: true,
		},
	},
	{
		timestamps: true,
	},
);

sessionSchema.index({ exportedAt: 1 }, { expireAfterSeconds: 0 });

export const SessionModel =
	mongoose.models.Session || mongoose.model("Session", sessionSchema);
