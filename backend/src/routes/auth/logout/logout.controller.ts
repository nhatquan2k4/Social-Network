import { Request, Response } from 'express';
import { LogoutService } from './logout.service.js';

const logoutService = new LogoutService();
const isProduction = process.env.NODE_ENV === 'production';

export const logout = async (req: Request, res: Response) => {
    try {
        const token = req.cookies?.refreshToken;

        if (!token) {
            return res
                .status(400)
                .json({ message: 'Khong tim thay refresh token' });
        }

        await logoutService.execute(token);

        res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'none' : 'lax',
        });

        return res.status(204).json({ message: 'Dang xuat thanh cong' });
    } catch (error) {
        console.error('Loi dang xuat nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
