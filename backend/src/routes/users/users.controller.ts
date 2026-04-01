import { Request, Response } from 'express';
import { UserService } from './users.service';
import { MediaService } from '../media/media.service';

const userService = new UserService();
const mediaService = new MediaService();

export const authMe = async (req: Request, res: Response) => {
    try {
        const user = req.user;
        if (!user) {
            return res.status(404).json({ message: 'Nguoi dung khong ton tai' });
        }
        return res.status(200).json({ user });
    } catch (error) {
        console.error('Loi khi lay thong tin nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const updateMyAvatar = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const files = (req.files || []) as Express.Multer.File[];

        if (!files.length) {
            return res.status(400).json({ message: 'Khong tim thay file avatar' });
        }

        const uploaded = await mediaService.uploadFiles([files[0] as Express.Multer.File], 'avatar', userId.toString());
        const avatar = uploaded[0];

        if (!avatar) {
            return res.status(500).json({ message: 'Khong the upload avatar' });
        }

        const user = await userService.updateAvatar(userId, {
            avatarUrl: avatar.mediaUrl,
            avatarPublicId: avatar.objectKey,
            avatarBucket: avatar.bucket,
            avatarObjectKey: avatar.objectKey,
        });

        return res.status(200).json({ message: 'Cap nhat avatar thanh cong', user });
    } catch (error: any) {
        console.error('Loi khi cap nhat avatar:', error);
        if (
            error.message === 'Dinh dang file khong duoc ho tro' ||
            error.message === 'Kich thuoc file vuot qua gioi han' ||
            error.message === 'So luong file vuot qua gioi han'
        ) {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};