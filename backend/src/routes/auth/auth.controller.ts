import { Request, Response } from 'express';
import { AuthService } from './auth.service';

const authService = new AuthService();
const isProduction = process.env.NODE_ENV === 'production';

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
        if (error.message === 'Email da ton tai') {
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
            secure: isProduction,
            sameSite: isProduction ? 'none' : 'lax',
            maxAge: result.refreshTokenTTL * 1000
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
            secure: isProduction,
            sameSite: isProduction ? 'none' : 'lax'
        });

        return res.status(204).json({ message: 'Dang xuat thanh cong' });
    } catch (error) {
        console.error('Loi dang xuat nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const verifyEmail = async (req: Request, res: Response) => {
    try {
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({ message: 'Vui long cung cap token xac thuc' });
        }

        const result = await authService.verifyEmail(String(token));
        return res.status(200).json(result);
    } catch (error: any) {
        if (error.message === 'Token xac thuc khong hop le hoac da het han') {
            return res.status(400).json({ message: error.message });
        }
        console.error('Loi xac thuc email:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const resendEmailVerification = async (req: Request, res: Response) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Vui long cung cap email' });
        }

        const result = await authService.resendEmailVerification(String(email));
        return res.status(200).json(result);
    } catch (error: any) {
        if (error.message?.startsWith('Vui long doi')) {
            return res.status(429).json({ message: error.message });
        }
        if (error.message === 'Vui long cung cap email hop le') {
            return res.status(400).json({ message: error.message });
        }
        console.error('Loi gui lai email xac thuc:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
