import { Request, Response } from 'express';
import { LoginService } from './login.service.js';

const loginService = new LoginService();
const isProduction = process.env.NODE_ENV === 'production';

export const login = async (req: Request, res: Response) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap day du thong tin' });
        }

        const result = await loginService.execute({ username, password });

        res.cookie('refreshToken', result.refreshToken, {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'none' : 'lax',
            maxAge: result.refreshTokenTTL * 1000,
        });

        return res.status(200).json({
            message: `Nguoi dung ${result.username} dang nhap thanh cong`,
            accessToken: result.accessToken,
            isEmailVerified: result.isEmailVerified,
        });
    } catch (error: any) {
        if (error.message === 'Sai ten dang nhap hoac mat khau') {
            return res.status(401).json({ message: error.message });
        }

        console.error('Loi dang nhap nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
