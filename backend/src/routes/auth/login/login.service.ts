import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { SessionRepository, UserRepository } from '../shared/auth.repo.js';
import { generateRefreshToken } from '../shared/auth.util.js';
import { ACCESS_TOKEN_TTL, REFRESH_TOKEN_TTL } from '../shared/auth.constants.js';
import { LoginDto } from './login.dto.js';
import type {
    LoginServiceDependencies,
    LoginServiceInterface,
    LoginSessionRepository,
    LoginUserRepository,
} from './login.service.interface.js';

export class LoginService implements LoginServiceInterface {
    private userRepository: LoginUserRepository;
    private sessionRepository: LoginSessionRepository;

    constructor(dependencies: LoginServiceDependencies = {}) {
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.sessionRepository = dependencies.sessionRepository ?? new SessionRepository();
    }

    async execute(loginData: LoginDto) {
        const { username, password } = loginData;
        const user = await this.userRepository.findByUsername(username);

        if (!user) {
            throw new Error('Sai ten dang nhap hoac mat khau');
        }

        const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);
        if (!isPasswordValid) {
            throw new Error('Sai ten dang nhap hoac mat khau');
        }

        const accessToken = jwt.sign(
            {
                userId: user._id,
                username: user.username,
            },
            process.env.ACCESS_TOKEN_SECRET as string,
            { expiresIn: ACCESS_TOKEN_TTL },
        );

        const refreshToken = generateRefreshToken();

        await this.sessionRepository.create({
            userId: user._id,
            refreshToken,
            exportedAt: new Date(Date.now() + REFRESH_TOKEN_TTL * 1000),
        });

        return {
            accessToken,
            refreshToken,
            refreshTokenTTL: REFRESH_TOKEN_TTL,
            username: user.username,
            isEmailVerified: Boolean(user.isEmailVerified),
        };
    }
}
