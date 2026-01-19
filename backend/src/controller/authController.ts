import { Request, Response } from 'express';
import { AuthService } from '../services/authService';

const authService = new AuthService();

export const register = async (req: Request, res: Response) => {
    try {
        const { username, password, email, firstName, lastName } = req.body;

        if (!username || !password || !email || !firstName || !lastName) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap day du thong tin' });
        }

        const result = await authService.register({
            username,
            password,
            email,
            firstName,
            lastName
        });

        return res.status(201).json(result);
    } catch (error: any) {
        if (error.message === 'Username da ton tai') {
            return res.status(409).json({ message: error.message });
        }
        console.error('Loi dang ky nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const login = async (req: Request, res: Response) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap day du thong tin' });
        }

        const result = await authService.login(username, password);

        // Gui refresh token qua cookie
        res.cookie('refreshToken', result.refreshToken, {
            httpOnly: true,
            secure: true,
            sameSite: 'none',
            maxAge: result.refreshTokenTTL * 1000
        });

        return res.status(200).json({
            message: `Nguoi dung ${result.username} dang nhap thanh cong`,
            accessToken: result.accessToken
        });
    } catch (error: any) {
        if (error.message === 'Sai ten dang nhap hoac mat khau') {
            return res.status(401).json({ message: error.message });
        }
        console.error('Loi dang nhap nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const logout = async (req: Request, res: Response) => {
    try {
        const token = req.cookies?.refreshToken;

        if (!token) {
            return res
                .status(400)
                .json({ message: 'Khong tim thay refresh token' });
        }

        await authService.logout(token);

        res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: true,
            sameSite: 'none'
        });

        return res.status(204).json({ message: 'Dang xuat thanh cong' });
    } catch (error) {
        console.error('Loi dang xuat nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
