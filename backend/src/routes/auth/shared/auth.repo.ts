import { Types } from 'mongoose';
import {
    EmailVerificationTokenModel as EmailVerificationToken,
    SessionModel as Session,
} from './auth.model';

export { UserRepository } from '../../users/shared/users.repo';

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

export class EmailVerificationTokenRepository {
    async create(tokenData: {
        userId: Types.ObjectId;
        tokenHash: string;
        expiresAt: Date;
    }) {
        return await EmailVerificationToken.create(tokenData);
    }

    async findValidByHash(tokenHash: string) {
        return await EmailVerificationToken.findOne({
            tokenHash,
            consumedAt: null,
            expiresAt: { $gt: new Date() },
        });
    }

    async consumeById(tokenId: string | Types.ObjectId) {
        return await EmailVerificationToken.findByIdAndUpdate(
            tokenId,
            { $set: { consumedAt: new Date() } },
            { new: true },
        );
    }

    async consumeAllActiveByUserId(userId: string | Types.ObjectId) {
        return await EmailVerificationToken.updateMany(
            { userId, consumedAt: null },
            { $set: { consumedAt: new Date() } },
        );
    }
}
