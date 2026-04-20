import { envConfig } from '../../../../shared/config/env';
import {
    EmailVerificationTokenRepository,
    UserRepository,
} from '../../shared/auth.repo.js';
import { issueEmailVerification } from '../../shared/auth.util.js';

export class ResendEmailVerificationService {
    private userRepository: UserRepository;
    private emailVerificationTokenRepository: EmailVerificationTokenRepository;

    constructor() {
        this.userRepository = new UserRepository();
        this.emailVerificationTokenRepository = new EmailVerificationTokenRepository();
    }

    async execute(email: string) {
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

        const verification = await issueEmailVerification(
            {
                _id: user._id,
                email: user.email,
                displayName: user.displayName,
            },
            {
                userRepository: this.userRepository,
                emailVerificationTokenRepository: this.emailVerificationTokenRepository,
            },
        );

        return {
            message: verification.sent
                ? 'Da gui lai email xac thuc'
                : 'Khong the gui email luc nay. Vui long thu lai sau',
            emailVerificationSent: verification.sent,
        };
    }
}
