import { Types } from "mongoose";
import { PostModel as Post } from "./posts.model";

export interface PostMediaInput {
	bucket: string;
	objectKey: string;
	mimeType: string;
	size: number;
}

export class PostRepository {
	async create(postData: {
		authorId: Types.ObjectId;
		content?: string;
		media?: PostMediaInput[];
	}) {
		return Post.create(postData);
	}

	async findById(postId: string) {
		return Post.findById(postId).populate("authorId", "displayName avatarUrl username");
	}

	async findRawById(postId: string) {
		return Post.findById(postId);
	}

	async findFeed(preferredAuthorIds: Types.ObjectId[], skip: number, limit: number) {
		const data = await Post.aggregate([
			{
				$addFields: {
					priority: {
						$cond: [{ $in: ["$authorId", preferredAuthorIds] }, 0, 1],
					},
				},
			},
			{ $sort: { priority: 1, createdAt: -1 } },
			{ $skip: skip },
			{ $limit: limit },
			{
				$project: {
					priority: 0,
				},
			},
		]);

		return Post.populate(data, {
			path: "authorId",
			select: "displayName avatarUrl username",
		});
	}

	async countAll() {
		return Post.countDocuments();
	}

	async deleteById(postId: string) {
		return Post.findByIdAndDelete(postId);
	}

	async toggleLike(postId: string, userId: Types.ObjectId) {
		const post = await Post.findById(postId);
		if (!post) {
			return null;
		}

		const hasLiked = post.likes.some((id: Types.ObjectId) => id.toString() === userId.toString());

		if (hasLiked) {
			post.likes = post.likes.filter((id: Types.ObjectId) => id.toString() !== userId.toString()) as any;
		} else {
			post.likes.push(userId);
		}

		await post.save();
		return post;
	}

	async addComment(
		postId: string,
		authorId: Types.ObjectId,
		content: string,
		parentCommentId?: string,
	) {
		return Post.findByIdAndUpdate(
			postId,
			{
				$push: {
					comments: {
						parentCommentId: parentCommentId || null,
						authorId,
						content,
						createdAt: new Date(),
						updatedAt: new Date(),
					},
				},
				$inc: { commentsCount: 1 },
			},
			{ new: true },
		).populate("comments.authorId", "username displayName avatarUrl");
	}

	async getComments(postId: string) {
		return Post.findById(postId)
			.select("comments commentsCount")
			.populate("comments.authorId", "username displayName avatarUrl")
			.lean();
	}

	async save(post: any) {
		return post.save();
	}
}
