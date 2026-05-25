import { EmailVerificationTokenRepository, UserRepository } from '../../shared/auth.repo.js';
import { hashVerificationToken } from '../../shared/auth.util.js';
import type {
    VerifyEmailServiceDependencies,
    VerifyEmailServiceInterface,
    VerifyEmailTokenRepository,
    VerifyEmailUserRepository,
} from './verify.service.interface.js';

export class VerifyEmailService implements VerifyEmailServiceInterface {
    private userRepository: VerifyEmailUserRepository;
    private emailVerificationTokenRepository: VerifyEmailTokenRepository;

    constructor(dependencies: VerifyEmailServiceDependencies = {}) {
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.emailVerificationTokenRepository =
            dependencies.emailVerificationTokenRepository ??
            new EmailVerificationTokenRepository();
    }

    async execute(rawToken: string) {
        const normalizedToken = String(rawToken || '').trim();
        if (!normalizedToken) {
            throw new Error('Token xac thuc khong hop le hoac da het han');
        }

        const tokenHash = hashVerificationToken(normalizedToken);
        const verificationToken =
            await this.emailVerificationTokenRepository.findValidByHash(tokenHash);

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
}
