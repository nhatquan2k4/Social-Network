import { Request, Response } from 'express';
import { VerifyEmailService } from './verify.service.js';
import type { VerifyEmailServiceInterface } from './verify.service.interface.js';

const verifyEmailService: VerifyEmailServiceInterface = new VerifyEmailService();

export const verifyEmail = async (req: Request, res: Response) => {
    try {
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({ message: 'Vui long cung cap token xac thuc' });
        }

        const result = await verifyEmailService.execute(String(token));
        return res.status(200).json(result);
    } catch (error: any) {
        if (error.message === 'Token xac thuc khong hop le hoac da het han') {
            return res.status(400).json({ message: error.message });
        }

        console.error('Loi xac thuc email:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};
