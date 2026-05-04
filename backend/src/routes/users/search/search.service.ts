import { Types } from 'mongoose';
import { UserRepository } from '../shared/users.repo.js';
import { parseSearchLimit, parseSearchName, parseSearchPage } from './search.dto.js';

export class SearchService {
    private userRepository: UserRepository;

    constructor() {
        this.userRepository = new UserRepository();
    }

    async searchUsers(
        rawName: unknown,
        rawPage: unknown,
        rawLimit: unknown,
        currentUserId: Types.ObjectId,
    ) {
        const name = parseSearchName(rawName);
        const page = parseSearchPage(rawPage);
        const limit = parseSearchLimit(rawLimit);

        const { users, total } = await this.userRepository.searchByDisplayName(
            name,
            currentUserId,
            page,
            limit,
        );

        return {
            data: users,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
                hasMore: page * limit < total,
            },
        };
    }
}
