import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { UserRepository } from './auth.repo';
import { EmailVerificationTokenRepository, SessionRepository } from './auth.repo';
import { Types } from 'mongoose';
import { envConfig } from '../../shared/config/env';
import { sendEmailVerificationEmail } from '../../shared/utils/email.service';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60; // 14 ngay

export class AuthService {
    private userRepository: UserRepository;
    private sessionRepository: SessionRepository;
    private emailVerificationTokenRepository: EmailVerificationTokenRepository;

    constructor() {
        this.userRepository = new UserRepository();
        this.sessionRepository = new SessionRepository();
        this.emailVerificationTokenRepository = new EmailVerificationTokenRepository();
    }

    private generateVerificationToken() {
        return crypto.randomBytes(32).toString('hex');
    }

    private hashVerificationToken(rawToken: string) {
        return crypto.createHash('sha256').update(rawToken).digest('hex');
    }

    private async issueEmailVerification(user: {
        _id: Types.ObjectId;
        email: string;
        displayName?: string;
    }) {
        await this.emailVerificationTokenRepository.consumeAllActiveByUserId(user._id);

        const rawToken = this.generateVerificationToken();
        const tokenHash = this.hashVerificationToken(rawToken);
        const expiresAt = new Date(Date.now() + envConfig.emailVerificationTokenTtlSeconds * 1000);
        const sentAt = new Date();

        await this.emailVerificationTokenRepository.create({
            userId: user._id,
            tokenHash,
            expiresAt,
        });

        await this.userRepository.setEmailVerificationSentAt(user._id, sentAt);

        const emailResult = await sendEmailVerificationEmail(
            user.email,
            user.displayName || user.email,
            rawToken,
        );

        return {
            sent: emailResult.sent,
            expiresAt: expiresAt.toISOString(),
        };
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

        const duplicateEmail = await this.userRepository.findByEmail(email);
        if (duplicateEmail) {
            throw new Error('Email da ton tai');
        }

        // Ma hoa mat khau
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Tao user moi
        const user = await this.userRepository.create({
            username,
            hashedPassword,
            email,
            displayName: `${firstName} ${lastName}`,
            isEmailVerified: false,
            emailVerifiedAt: null,
            emailVerificationSentAt: null,
        });

        const verification = await this.issueEmailVerification({
            _id: user._id,
            email: user.email,
            displayName: user.displayName,
        });

        return {
            message: verification.sent
                ? 'Dang ky thanh cong. Vui long kiem tra email de xac thuc tai khoan'
                : 'Dang ky thanh cong. Chua the gui email xac thuc luc nay',
            requiresEmailVerification: true,
            emailVerificationSent: verification.sent,
        };
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
            username: user.username,
            isEmailVerified: Boolean(user.isEmailVerified),
        };
    }

    async verifyEmail(rawToken: string) {
        const normalizedToken = String(rawToken || '').trim();
        if (!normalizedToken) {
            throw new Error('Token xac thuc khong hop le hoac da het han');
        }

        const tokenHash = this.hashVerificationToken(normalizedToken);
        const verificationToken = await this.emailVerificationTokenRepository.findValidByHash(tokenHash);

        if (!verificationToken) {
            throw new Error('Token xac thuc khong hop le hoac da het han');
        }

        const user = await this.userRepository.findById(verificationToken.userId);
        if (!user) {
            await this.emailVerificationTokenRepository.consumeById(verificationToken._id);
            throw new Error('Token xac thuc khong hop le hoac da het han');
        }

        if (!user.isEmailVerified) {
            await this.userRepository.markEmailVerified(user._id);
        }

        await this.emailVerificationTokenRepository.consumeById(verificationToken._id);
        await this.emailVerificationTokenRepository.consumeAllActiveByUserId(user._id);

        return { message: 'Xac thuc email thanh cong' };
    }

    async resendEmailVerification(email: string) {
        const normalizedEmail = String(email || '').toLowerCase().trim();
        if (!normalizedEmail) {
            throw new Error('Vui long cung cap email hop le');
        }

        const user = await this.userRepository.findByEmail(normalizedEmail);

        if (!user) {
            return {
                message: 'Neu email hop le, chung toi da gui lai email xac thuc',
                emailVerificationSent: false,
            };
        }

        if (user.isEmailVerified) {
            return {
                message: 'Email da duoc xac thuc truoc do',
                emailVerificationSent: false,
            };
        }

        if (user.emailVerificationSentAt) {
            const lastSentAt = new Date(user.emailVerificationSentAt).getTime();
            const cooldownMs = envConfig.emailVerificationResendCooldownSeconds * 1000;
            const elapsed = Date.now() - lastSentAt;

            if (elapsed < cooldownMs) {
                const waitSeconds = Math.ceil((cooldownMs - elapsed) / 1000);
                throw new Error(`Vui long doi ${waitSeconds} giay de gui lai email xac thuc`);
            }
        }

        const verification = await this.issueEmailVerification({
            _id: user._id,
            email: user.email,
            displayName: user.displayName,
        });

        return {
            message: verification.sent
                ? 'Da gui lai email xac thuc'
                : 'Khong the gui email luc nay. Vui long thu lai sau',
            emailVerificationSent: verification.sent,
        };
    }

    async logout(refreshToken: string) {
        await this.sessionRepository.deleteByRefreshToken(refreshToken);
    }

    getRefreshTokenTTL() {
        return REFRESH_TOKEN_TTL;
    }
}
