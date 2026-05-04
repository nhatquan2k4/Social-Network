import { Request, Response, NextFunction } from 'express';

/**
 * Admin middleware — yêu cầu user đã authenticated (protectedRoute) VÀ có role = "admin".
 * Phải đặt SAU protectedRoute trong middleware chain.
 */
export const adminRoute = (req: Request, res: Response, next: NextFunction) => {
    const user = req.user as any;

    if (!user) {
        return res
            .status(401)
            .json({ message: 'Chua xac thuc. Vui long dang nhap' });
    }

    if (user.role !== 'admin') {
        return res
            .status(403)
            .json({ message: 'Khong co quyen truy cap. Yeu cau quyen admin' });
    }

    next();
};
