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

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res
                .status(400)
                .json({ message: 'Email khong dung dinh dang' });
        }

        if (password.length < 6) {
            return res
                .status(400)
                .json({ message: 'Mat khau phai co it nhat 6 ky tu' });
        }

        const usernameRegex = /^[a-zA-Z0-9_]{3,30}$/;
        if (!usernameRegex.test(username)) {
            return res
                .status(400)
                .json({ message: 'Username tu 3 den 30 ky tu va khong chua ky tu dac biet' });
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
