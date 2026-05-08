import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { UserRepository } from '../shared/auth.repo.js';
import { UserNotFoundByEmailError } from '../shared/auth.errors.js';
import { sendForgotPasswordEmail } from '../../../shared/utils/email.service.js';
import { ForgotPasswordDto } from './forgot-password.dto.js';

const SALT_ROUNDS = 10;
const NEW_PASSWORD_LENGTH = 12;

const generateRandomPassword = (): string => {
    // Tạo password ngẫu nhiên gồm chữ + số + ký tự đặc biệt (12 ký tự)
    const charset = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%';
    const bytes = crypto.randomBytes(NEW_PASSWORD_LENGTH);
    return Array.from(bytes)
        .map((b) => charset[b % charset.length])
        .join('');
};

export class ForgotPasswordService {
    private userRepository: UserRepository;

    constructor() {
        this.userRepository = new UserRepository();
    }

    async execute(dto: ForgotPasswordDto) {
        const { email } = dto;

        // Tìm user theo email
        const user = await this.userRepository.findByEmail(email);
        if (!user) {
            throw new UserNotFoundByEmailError();
        }

        // Sinh mật khẩu mới ngẫu nhiên
        const newPassword = generateRandomPassword();
        const hashedPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);

        // Cập nhật DB trước khi gửi mail
        await this.userRepository.updatePassword(user._id, hashedPassword);

        // Gửi mail mật khẩu mới
        const result = await sendForgotPasswordEmail(
            user.email,
            user.displayName || user.username,
            newPassword,
        );

        return { sent: result.sent };
    }
}
