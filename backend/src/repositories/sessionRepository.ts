import { Session } from '../models/session';
import { Types } from 'mongoose';

export class SessionRepository {
    async create(sessionData: {
        userId: Types.ObjectId;
        refreshToken: string;
        exportedAt: Date;
    }) {
        return await Session.create(sessionData);
    }

    async deleteByRefreshToken(refreshToken: string) {
        return await Session.deleteOne({ refreshToken });
    }

    async findByRefreshToken(refreshToken: string) {
        return await Session.findOne({ refreshToken });
    }
}
