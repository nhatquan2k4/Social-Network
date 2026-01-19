import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { UserRepository } from '../repositories/userRepository';
import { SessionRepository } from '../repositories/sessionRepository';
import { Types } from 'mongoose';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60; // 14 ngay

export class AuthService {
    private userRepository: UserRepository;
    private sessionRepository: SessionRepository;

    constructor() {
        this.userRepository = new UserRepository();
        this.sessionRepository = new SessionRepository();
    }

    async register(userData: {
        username: string;
        password: string;
        email: string;
        firstName: string;
        lastName: string;
    }) {
        const { username, password, email, firstName, lastName } = userData;

        // Kiem tra user da ton tai
        const duplicateUser = await this.userRepository.findByUsername(username);
        if (duplicateUser) {
            throw new Error('Username da ton tai');
        }

        // Ma hoa mat khau
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Tao user moi
        await this.userRepository.create({
            username,
            hashedPassword,
            email,
            displayName: `${firstName} ${lastName}`
        });

        return { message: 'Dang ky thanh cong' };
    }

    async login(username: string, password: string) {
        // Lay user
        const user = await this.userRepository.findByUsername(username);
        if (!user) {
            throw new Error('Sai ten dang nhap hoac mat khau');
        }

        // Kiem tra password
        const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);
        if (!isPasswordValid) {
            throw new Error('Sai ten dang nhap hoac mat khau');
        }

        // Tao access token
        const accessToken = jwt.sign(
            {
                userId: user._id,
                username: user.username
            },
            process.env.ACCESS_TOKEN_SECRET as string,
            { expiresIn: ACCESS_TOKEN_TTL }
        );

        // Tao refresh token
        const refreshToken = crypto.randomBytes(64).toString('hex');

        // Luu session vao db
        await this.sessionRepository.create({
            userId: user._id,
            refreshToken,
            exportedAt: new Date(Date.now() + REFRESH_TOKEN_TTL * 1000)
        });

        return {
            accessToken,
            refreshToken,
            refreshTokenTTL: REFRESH_TOKEN_TTL,
            username: user.username
        };
    }

    async logout(refreshToken: string) {
        await this.sessionRepository.deleteByRefreshToken(refreshToken);
    }

    getRefreshTokenTTL() {
        return REFRESH_TOKEN_TTL;
    }
}
