import type { UserRepositoryInterface } from '../shared/users.repo.interface.js';
import type { SearchService } from './search.service.js';

export type SearchUserRepository = Pick<UserRepositoryInterface, 'searchByDisplayName'>;

export interface SearchServiceDependencies {
    userRepository?: SearchUserRepository;
}

export interface SearchServiceInterface {
    searchUsers: SearchService['searchUsers'];
}
