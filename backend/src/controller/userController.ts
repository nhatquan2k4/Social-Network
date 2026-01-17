import express, { Request, Response } from 'express';

export const authMe = async (req: Request, res: Response) => {
    try{
        const user = req.user;
        if (!user) {
            return res.status(404).json({ message: 'Nguoi dung khong ton tai' });
        }
        return res.status(200).json({ user });
    } catch (error) {
        console.error('Loi khi lay thong tin nguoi dung:', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};