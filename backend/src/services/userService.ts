import { UserRepository } from '../repositories/userRepository';
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
}
