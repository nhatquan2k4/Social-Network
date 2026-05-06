import { Request, Response } from 'express';
import { ForgotPasswordService } from './forgot-password.service.js';
import { UserNotFoundByEmailError } from '../shared/auth.errors.js';

const forgotPasswordService = new ForgotPasswordService();

export const forgotPassword = async (req: Request, res: Response) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap email' });
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res
                .status(400)
                .json({ message: 'Email khong hop le' });
        }

        const result = await forgotPasswordService.execute({ email });

        return res.status(200).json({
            message: result.sent
                ? 'Mat khau moi da duoc gui den email cua ban'
                : 'Mat khau moi da duoc tao nhung email chua duoc gui (SMTP chua cau hinh)',
        });
    } catch (error: any) {
        if (error instanceof UserNotFoundByEmailError) {
            return res.status(404).json({ message: error.message });
        }

        console.error('Loi quen mat khau:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
