import jwt from 'jsonwebtoken';
import { SessionRepository, UserRepository } from '../shared/auth.repo.js';
import { generateRefreshToken } from '../shared/auth.util.js';
import { ACCESS_TOKEN_TTL, REFRESH_TOKEN_TTL } from '../shared/auth.constants.js';
import { InvalidRefreshTokenError } from '../shared/auth.errors.js';
import { RefreshTokenDto } from './refresh-token.dto.js';

export class RefreshTokenService {
    private sessionRepository: SessionRepository;
    private userRepository: UserRepository;

    constructor() {
        this.sessionRepository = new SessionRepository();
        this.userRepository = new UserRepository();
    }

    async execute(dto: RefreshTokenDto) {
        const { refreshToken } = dto;

        // Tìm session theo refresh token
        const session = await this.sessionRepository.findByRefreshToken(refreshToken);
        if (!session) {
            throw new InvalidRefreshTokenError();
        }

        // Kiểm tra session còn hạn (exportedAt là thời điểm hết hạn)
        if (session.exportedAt < new Date()) {
            await this.sessionRepository.deleteByRefreshToken(refreshToken);
            throw new InvalidRefreshTokenError();
        }

        // Kiểm tra user tồn tại
        const user = await this.userRepository.findById(session.userId.toString());
        if (!user) {
            await this.sessionRepository.deleteByRefreshToken(refreshToken);
            throw new InvalidRefreshTokenError();
        }

        // Token rotation: xóa session cũ, tạo session mới
        await this.sessionRepository.deleteByRefreshToken(refreshToken);

        const newAccessToken = jwt.sign(
            {
                userId: user._id,
                username: user.username,
            },
            process.env.ACCESS_TOKEN_SECRET as string,
            { expiresIn: ACCESS_TOKEN_TTL },
        );

        const newRefreshToken = generateRefreshToken();

        await this.sessionRepository.create({
            userId: user._id,
            refreshToken: newRefreshToken,
            exportedAt: new Date(Date.now() + REFRESH_TOKEN_TTL * 1000),
        });

        return {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            refreshTokenTTL: REFRESH_TOKEN_TTL,
        };
    }
}
