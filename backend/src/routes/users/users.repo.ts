import { UserModel as User } from './users.model';
import { Types } from 'mongoose';

export class UserRepository {
	async findByUsername(username: string) {
		return await User.findOne({ username });
	}

	async findById(userId: string | Types.ObjectId) {
		return await User.findById(userId);
	}

	async exists(userId: string | Types.ObjectId) {
		return await User.exists({ _id: userId });
	}

	async create(userData: {
		username: string;
		hashedPassword: string;
		email: string;
		displayName: string;
	}) {
		const newUser = new User(userData);
		return await newUser.save();
	}

	async findByIdWithFields(userId: string | Types.ObjectId, fields: string) {
		return await User.findById(userId).select(fields).lean();
	}

	async findProfileById(userId: string | Types.ObjectId) {
		return await User.findById(userId)
			.select('_id username displayName avatarUrl bio createdAt updatedAt')
			.lean();
	}

	async updateProfile(
		userId: string | Types.ObjectId,
		setData: Record<string, unknown>,
		unsetFields: string[],
	) {
		const updateQuery: Record<string, unknown> = {};

		if (Object.keys(setData).length > 0) {
			updateQuery.$set = setData;
		}

		if (unsetFields.length > 0) {
			const unsetQuery: Record<string, 1> = {};
			unsetFields.forEach((field) => {
				unsetQuery[field] = 1;
			});
			updateQuery.$unset = unsetQuery;
		}

		return await User.findByIdAndUpdate(userId, updateQuery, { new: true }).select('-hashedPassword');
	}

	async updateAvatar(
		userId: string | Types.ObjectId,
		avatarData: { avatarUrl: string; avatarPublicId: string; avatarBucket: string; avatarObjectKey: string },
	) {
		return await User.findByIdAndUpdate(
			userId,
			{
				$set: {
					avatarUrl: avatarData.avatarUrl,
					avatarPublicId: avatarData.avatarPublicId,
					avatarBucket: avatarData.avatarBucket,
					avatarObjectKey: avatarData.avatarObjectKey,
				},
			},
			{ new: true },
		).select('-hashedPassword');
	}
}
