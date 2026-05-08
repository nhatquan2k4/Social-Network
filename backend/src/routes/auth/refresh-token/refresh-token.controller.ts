import { Request, Response } from 'express';
import { RefreshTokenService } from './refresh-token.service.js';
import { InvalidRefreshTokenError } from '../shared/auth.errors.js';

const refreshTokenService = new RefreshTokenService();
const isProduction = process.env.NODE_ENV === 'production';

export const refreshToken = async (req: Request, res: Response) => {
    try {
        // Ưu tiên cookie (web), fallback sang body (mobile Flutter)
        const token = req.cookies?.refreshToken ?? req.body?.refreshToken;

        if (!token) {
            return res
                .status(401)
                .json({ message: 'Khong tim thay refresh token' });
        }

        const result = await refreshTokenService.execute({ refreshToken: token });

        // Set cookie refresh token mới (token rotation)
        res.cookie('refreshToken', result.refreshToken, {
            httpOnly: true,
            secure: isProduction,
            sameSite: isProduction ? 'none' : 'lax',
            maxAge: result.refreshTokenTTL * 1000,
        });

        return res.status(200).json({
            message: 'Cap moi access token thanh cong',
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,   // mobile client cập nhật lại refresh token
        });
    } catch (error: any) {
        if (error instanceof InvalidRefreshTokenError) {
            return res.status(401).json({ message: error.message });
        }

        console.error('Loi cap moi access token:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
