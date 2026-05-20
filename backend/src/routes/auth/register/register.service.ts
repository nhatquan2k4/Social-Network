import bcrypt from 'bcrypt';
import { EmailVerificationTokenRepository, UserRepository } from '../shared/auth.repo.js';
import { issueEmailVerification } from '../shared/auth.util.js';
import { RegisterDto } from './register.dto.js';
import type {
    RegisterEmailVerificationTokenRepository,
    RegisterServiceDependencies,
    RegisterServiceInterface,
    RegisterUserRepository,
} from './register.service.interface.js';

export class RegisterService implements RegisterServiceInterface {
    private userRepository: RegisterUserRepository;
    private emailVerificationTokenRepository: RegisterEmailVerificationTokenRepository;

    constructor(dependencies: RegisterServiceDependencies = {}) {
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.emailVerificationTokenRepository =
            dependencies.emailVerificationTokenRepository ??
            new EmailVerificationTokenRepository();
    }

    async execute(userData: RegisterDto) {
        const { username, password, email, firstName, lastName } = userData;

        const duplicateUser = await this.userRepository.findByUsername(username);
        if (duplicateUser) {
            throw new Error('Username da ton tai');
        }

        const duplicateEmail = await this.userRepository.findByEmail(email);
        if (duplicateEmail) {
            throw new Error('Email da ton tai');
        }

        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const user = await this.userRepository.create({
            username,
            hashedPassword,
            email,
            displayName: `${firstName} ${lastName}`,
            isEmailVerified: false,
            emailVerifiedAt: null,
            emailVerificationSentAt: null,
        });

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
                ? 'Dang ky thanh cong. Vui long kiem tra email de xac thuc tai khoan'
                : 'Dang ky thanh cong. Chua the gui email xac thuc luc nay',
            requiresEmailVerification: true,
            emailVerificationSent: verification.sent,
        };
    }
}
