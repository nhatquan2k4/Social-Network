import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
        username: { 
            type: String, 
            required: true, 
            unique: true,
            trim: true,
            lowercase: true, 
        },
        hashedPassword: { 
            type: String, 
            required: true
        },
        email: { 
            type: String,
            required: true,
            unique: true,
            trim: true,
            lowercase: true,
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
        bio: {
            type: String,
            maxlength: 500,
        },
        phone: {
            type: String,
            sparse: true, // cho phép giá trị null cho trường này, nhưng ko được trùng
        },
    },
    {
        timestamps: true,
    },
);

const User = mongoose.model('User', userSchema);
export default User;