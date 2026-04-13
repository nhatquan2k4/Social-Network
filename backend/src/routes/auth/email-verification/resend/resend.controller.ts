import { Request, Response } from 'express';
import { ResendEmailVerificationService } from './resend.service';

const resendEmailVerificationService = new ResendEmailVerificationService();

export const resendEmailVerification = async (req: Request, res: Response) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Vui long cung cap email' });
        }

        const result = await resendEmailVerificationService.execute(String(email));
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
