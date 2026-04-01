import mongoose from "mongoose";

const messageMediaSchema = new mongoose.Schema(
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

const messageSchema = new mongoose.Schema(
	{
		conversationId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "Conversation",
			required: true,
			index: true,
		},
		senderId: {
			type: mongoose.Schema.Types.ObjectId,
			ref: "User",
			required: true,
		},
		content: {
			type: String,
			trim: true,
		},
		media: {
			type: [messageMediaSchema],
			default: [],
		},
		imgUrl: {
			type: String,
		},
	},
	{
		timestamps: true,
	},
);

messageSchema.index({ conversationId: 1, createdAt: -1 });

export const MessageModel =
	mongoose.models.Message || mongoose.model("Message", messageSchema);
