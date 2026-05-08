import bcrypt from 'bcrypt';
import { Types } from 'mongoose';
import { UserRepository } from '../shared/auth.repo.js';
import { WrongCurrentPasswordError } from '../shared/auth.errors.js';
import { ChangePasswordDto } from './change-password.dto.js';

const SALT_ROUNDS = 10;

export class ChangePasswordService {
    private userRepository: UserRepository;

    constructor() {
        this.userRepository = new UserRepository();
    }

    async execute(userId: string | Types.ObjectId, dto: ChangePasswordDto) {
        const { currentPassword, newPassword } = dto;

        // Lấy user kèm hashedPassword (mặc định findById đã lấy tất cả fields)
        const user = await this.userRepository.findById(userId);
        if (!user) {
            throw new WrongCurrentPasswordError();
        }

        // Xác minh mật khẩu hiện tại
        const isMatch = await bcrypt.compare(currentPassword, user.hashedPassword);
        if (!isMatch) {
            throw new WrongCurrentPasswordError();
        }

        // Hash mật khẩu mới
        const hashedPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);

        await this.userRepository.updatePassword(userId, hashedPassword);
    }
}
