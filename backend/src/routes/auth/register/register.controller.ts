import { Request, Response } from 'express';
import { RegisterService } from './register.service.js';
import type { RegisterServiceInterface } from './register.service.interface.js';

const registerService: RegisterServiceInterface = new RegisterService();

export const register = async (req: Request, res: Response) => {
    try {
        const { username, password, email, firstName, lastName } = req.body;

        if (!username || !password || !email || !firstName || !lastName) {
            return res
                .status(400)
                .json({ message: 'Vui long cung cap day du thong tin' });
        }

        const result = await registerService.execute({
            username,
            password,
            email,
            firstName,
            lastName,
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
