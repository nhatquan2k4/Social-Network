import { UserRepository } from './users.repo';
import { Types } from 'mongoose';

export class UserService {
    private userRepository: UserRepository;

    constructor() {
        this.userRepository = new UserRepository();
    }

    async getUserById(userId: Types.ObjectId) {
        const user = await this.userRepository.findById(userId);
        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }
        return user;
    }

    async updateAvatar(
        userId: Types.ObjectId,
        avatarData: { avatarUrl: string; avatarPublicId: string; avatarBucket: string; avatarObjectKey: string },
    ) {
        const user = await this.userRepository.updateAvatar(userId, avatarData);
        if (!user) {
            throw new Error('Nguoi dung khong ton tai');
        }
        return user;
    }
}
