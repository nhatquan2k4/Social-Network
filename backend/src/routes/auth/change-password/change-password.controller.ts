import { Request, Response } from 'express';
import { ChangePasswordService } from './change-password.service.js';
import type { ChangePasswordServiceInterface } from './change-password.service.interface.js';
import { WrongCurrentPasswordError } from '../shared/auth.errors.js';

const changePasswordService: ChangePasswordServiceInterface = new ChangePasswordService();

export const changePassword = async (req: Request, res: Response) => {
    try {
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap day du mat khau hien tai va mat khau moi' });
        }

        if (newPassword.length < 8) {
            return res
                .status(400)
                .json({ message: 'Mat khau moi phai co it nhat 8 ky tu' });
        }

        if (currentPassword === newPassword) {
            return res
                .status(400)
                .json({ message: 'Mat khau moi khong duoc trung voi mat khau hien tai' });
        }

        await changePasswordService.execute(req.user!._id, { currentPassword, newPassword });

        return res.status(200).json({ message: 'Doi mat khau thanh cong' });
    } catch (error: any) {
        if (error instanceof WrongCurrentPasswordError) {
            return res.status(401).json({ message: error.message });
        }

        console.error('Loi doi mat khau:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
