import { Request, Response } from 'express';
import { ProfileService } from './profile.service.js';
import type { ProfileServiceInterface } from './profile.service.interface.js';

const profileService: ProfileServiceInterface = new ProfileService();

export const getMe = async (req: Request, res: Response) => {
    try {
        const user = profileService.getMe(req.user);
        return res.status(200).json({ user });
    } catch (error: any) {
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }

        console.error('Loi khi lay thong tin nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const updateMe = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const hasDisplayNameField = Object.prototype.hasOwnProperty.call(
            req.body || {},
            'displayName',
        );
        const hasBioField = Object.prototype.hasOwnProperty.call(req.body || {}, 'bio');
        const hasPhoneField = Object.prototype.hasOwnProperty.call(req.body || {}, 'phone');

        const user = await profileService.updateMe(userId, {
            hasDisplayNameField,
            displayName: req.body?.displayName,
            hasBioField,
            bio: req.body?.bio,
            hasPhoneField,
            phone: req.body?.phone,
        });

        return res.status(200).json({ message: 'Cap nhat thong tin thanh cong', user });
    } catch (error: any) {
        console.error('Loi khi cap nhat profile user:', error);
        if (
            error.message === 'Khong co du lieu cap nhat' ||
            error.message === 'DisplayName khong duoc de trong'
        ) {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }

        return res.status(500).json({ message: 'Loi server' });
    }
};

export const updateAvatar = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const files = (req.files || []) as Express.Multer.File[];

        const user = await profileService.updateAvatar(userId, files);

        return res.status(200).json({ message: 'Cap nhat avatar thanh cong', user });
    } catch (error: any) {
        console.error('Loi khi cap nhat avatar:', error);
        if (error.message === 'Khong tim thay file avatar') {
            return res.status(400).json({ message: error.message });
        }
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

export const getUserProfile = async (req: Request, res: Response) => {
    try {
        const { userId } = req.params;
        const requesterId = req.user!._id;
        const data = await profileService.getUserProfile(userId as string, requesterId);

        return res.status(200).json({ data });
    } catch (error: any) {
        console.error('Loi khi lay profile user:', error);
        if (error.message === 'userId khong hop le') {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Khong the thuc hien hanh dong nay vi da co quan he block') {
            return res.status(403).json({ message: error.message });
        }

        return res.status(500).json({ message: 'Loi server' });
    }
};
