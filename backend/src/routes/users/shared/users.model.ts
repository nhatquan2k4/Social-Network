import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
    {
        username: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            lowercase: true,
        },
        hashedPassword: {
            type: String,
            required: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            lowercase: true,
        },
        isEmailVerified: {
            type: Boolean,
            default: false,
        },
        emailVerifiedAt: {
            type: Date,
            default: null,
        },
        emailVerificationSentAt: {
            type: Date,
            default: null,
        },
        displayName: {
            type: String,
            required: true,
            trim: true,
        },
        avatarUrl: {
            type: String,
        },
        avatarPublicId: {
            type: String,
        },
        avatarBucket: {
            type: String,
        },
        avatarObjectKey: {
            type: String,
        },
        bio: {
            type: String,
            maxlength: 500,
        },
        phone: {
            type: String,
            sparse: true,
        },
    },
    {
        timestamps: true,
    },
);

export const UserModel =
    mongoose.models.User || mongoose.model('User', userSchema);
