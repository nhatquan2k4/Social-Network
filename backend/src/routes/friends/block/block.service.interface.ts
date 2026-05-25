import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { BlockRepositoryInterface } from '../shared/friends.repo.interface.js';
import type { BlockService } from './block.service.js';

export type BlockUserRepository = Pick<UserRepositoryInterface, 'exists'>;
export type BlockServiceRepository = Pick<
    BlockRepositoryInterface,
    'findByUsers' | 'create' | 'deleteByUsers' | 'findBlockedByUserId'
>;

export interface BlockServiceDependencies {
    blockRepository?: BlockServiceRepository;
    userRepository?: BlockUserRepository;
}

export interface BlockServiceInterface {
    blockUser: BlockService['blockUser'];
    unblockUser: BlockService['unblockUser'];
    getBlockedUsers: BlockService['getBlockedUsers'];
}
