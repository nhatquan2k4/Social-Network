import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import User from '../models/user';


// authorization middleware - xac minh user la ai
export const protectedRoute = async ( req: Request, res: Response, next: NextFunction ) => {
    try {
        // lay token tu header
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(" ")[1]; // Bearer <TOKEN>

        if (!token) {
            return res
            .status(401)
            .json({ message: 'Khong tim thay access token. Vui long dang nhap' });
        }

        // xac nhan token hop le
        let decoded: any;
        try {
            decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET as string);
        } catch (err) {
            return res
            .status(403)
            .json({ message: 'Access token het han hoac khong hop le' });
        }
        
        // tim user
        const user = await User.findById(decoded.userId).select('-hashedPassword');
        if (!user) {
            return res
            .status(404)
            .json({ message: 'Nguoi dung khong ton tai' });
        }

        // tra user ve req de su dung o cac middleware sau
        req.user = user as any;
        next();
    } catch (error) {
        console.error('Loi khi xac minh JWT trong authMiddleware', error);
        return res
        .status(500)
        .json({ message: 'Loi server' });
    }
};