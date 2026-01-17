import mongoose from "mongoose";

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
        }
);

// tu dong xoa document khi het han
sessionSchema.index({ exportedAt: 1 }, { expireAfterSeconds: 0 });
        
export const Session = mongoose.model('Session', sessionSchema);