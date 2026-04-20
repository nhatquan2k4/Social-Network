import crypto from 'crypto';
import { Types } from 'mongoose';
import { envConfig } from '../../../shared/config/env.js';
import { sendEmailVerificationEmail } from '../../../shared/utils/email.service.js';
import { EmailVerificationTokenRepository, UserRepository } from './auth.repo.js';
import { ACCESS_TOKEN_TTL, REFRESH_TOKEN_TTL } from './auth.constants.js';

export { ACCESS_TOKEN_TTL, REFRESH_TOKEN_TTL };

export const generateRefreshToken = () => crypto.randomBytes(64).toString('hex');

const generateVerificationToken = () => crypto.randomBytes(32).toString('hex');

export const hashVerificationToken = (rawToken: string) =>
    crypto.createHash('sha256').update(rawToken).digest('hex');

export const issueEmailVerification = async (
    user: {
        _id: Types.ObjectId;
        email: string;
        displayName?: string;
    },
    deps: {
        userRepository: UserRepository;
        emailVerificationTokenRepository: EmailVerificationTokenRepository;
    },
) => {
    await deps.emailVerificationTokenRepository.consumeAllActiveByUserId(user._id);

    const rawToken = generateVerificationToken();
    const tokenHash = hashVerificationToken(rawToken);
    const expiresAt = new Date(
        Date.now() + envConfig.emailVerificationTokenTtlSeconds * 1000,
    );
    const sentAt = new Date();

    await deps.emailVerificationTokenRepository.create({
        userId: user._id,
        tokenHash,
        expiresAt,
    });

    await deps.userRepository.setEmailVerificationSentAt(user._id, sentAt);

    const emailResult = await sendEmailVerificationEmail(
        user.email,
        user.displayName || user.email,
        rawToken,
    );

    return {
        sent: emailResult.sent,
        expiresAt: expiresAt.toISOString(),
    };
};
