import mongoose from 'mongoose';

export { UserModel } from '../../users/shared/users.model.js';

const sessionSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
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
    mongoose.models.Session || mongoose.model('Session', sessionSchema);

const emailVerificationTokenSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        tokenHash: {
            type: String,
            required: true,
            unique: true,
            index: true,
        },
        expiresAt: {
            type: Date,
            required: true,
        },
        consumedAt: {
            type: Date,
            default: null,
        },
    },
    {
        timestamps: true,
    },
);

emailVerificationTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const EmailVerificationTokenModel =
    mongoose.models.EmailVerificationToken ||
    mongoose.model('EmailVerificationToken', emailVerificationTokenSchema);
