import express, { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import User from '../models/user';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Session } from '../models/session';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60; // 14 ngay

export const register = async (req: Request, res: Response) => {
    try {
        const {username, password, email, firstName, lastName} =  req.body;

        if (!username || !password || !email || !firstName || !lastName) {
            return res
            .status(400)
            .json({ 
                message: 
                'Vui long cung cap day du thong tin' 
            });
        }
        // Kiem tra xem user da ton tai chua
        const duplicateUser = await User.findOne({ username });
        if (duplicateUser) {
            return res
            .status(409)
            .json({ message: 'Username da ton tai' });
        }

        // Ma hoa mat khau
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Tao user moi
        const newUser = new User({
            username,
            hashedPassword,
            email,
            displayName: `${firstName} ${lastName}`,
        });

        await newUser.save();

        // return
        return res
        .status(201)
        .json({ message: 'Dang ky thanh cong' });
    } catch (error) {
        console.error('Loi dang ky nguoi dung:', error);
        return res
        .status(500)
        .json({ message: 'Loi server' });
    }
};

export const login = async (req: Request, res: Response) => {
    try {
        // lay input
        const { username, password } = req.body;
        if (!username || !password) {
            return res
            .status(400)
            .json({ message: 'Vui long cung cap day du thong tin' });
        }
        // lay hashedPassword trong db de so voi password input
        const user =  await User.findOne({ username });
        if (!user) {
            return res
            .status(401)
            .json({ message: 'Sai ten dang nhap hoac mat khau' });
        }

        // kiem tra password
        const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);
        if (!isPasswordValid) {
            return res
            .status(401)
            .json({ message: 'Sai ten dang nhap hoac mat khau' });
        }

        // neu khop, tao access token bang jwt va tra ve cho client
        const accessToken = jwt.sign(
            {
                userId: user._id,
                username: user.username,
            },
            process.env.ACCESS_TOKEN_SECRET as string,
            { expiresIn: ACCESS_TOKEN_TTL }
        );

        // tao refresh token va luu vao db
        const refreshToken = crypto.randomBytes(64).toString('hex');

        // tao session luu refresh token vao db
        await Session.create({
            userId: user._id,
            refreshToken,
            exportedAt: new Date(Date.now() + REFRESH_TOKEN_TTL * 1000),
        });

        // gui response ve client thong qua cookie
        res.cookie('refreshToken', refreshToken, {
            httpOnly: true,
            secure: true,
            sameSite: 'none',
            maxAge: REFRESH_TOKEN_TTL * 1000,
        });

        // tra access token ve response body
        return res
        .status(200)
        .json({ message: 
            `Nguoi dung ${user.username} dang nhap thanh cong`, 
            accessToken 
        });
    } catch (error) {
        console.error('Loi dang nhap nguoi dung:', error);
        return res
        .status(500)
        .json({ message: 'Loi server' });
    }
};    

export const logout = async (req: Request, res: Response) => {
    try {
        // lay refresh token tu cookie
        const token = req.cookies?.refreshToken;

        if (!token) {
            return res
            .status(400)
            .json({ message: 'Khong tim thay refresh token' });
        }

        await Session.deleteOne({ refreshToken: token });

        // xoa cookie tren client
        res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: true,
            sameSite: 'none',
        });
        
        return res
        .status(204)
        .json({ message: 'Dang xuat thanh cong' });



    } catch (error) {
        console.error('Loi dang xuat nguoi dung:', error);
        return res
        .status(500)
        .json({ message: 'Loi server' });
    }

};