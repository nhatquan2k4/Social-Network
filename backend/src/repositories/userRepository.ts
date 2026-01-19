import User from '../models/user';
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
}
