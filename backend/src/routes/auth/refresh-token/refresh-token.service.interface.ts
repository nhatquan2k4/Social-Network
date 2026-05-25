import type {
    SessionRepositoryInterface,
} from '../shared/auth.repo.interface.js';
import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { RefreshTokenService } from './refresh-token.service.js';

export type RefreshSessionRepository = Pick<
    SessionRepositoryInterface,
    'findByRefreshToken' | 'deleteByRefreshToken' | 'create'
>;
export type RefreshUserRepository = Pick<UserRepositoryInterface, 'findById'>;

export interface RefreshTokenServiceDependencies {
    sessionRepository?: RefreshSessionRepository;
    userRepository?: RefreshUserRepository;
}

export interface RefreshTokenServiceInterface {
    execute: RefreshTokenService['execute'];
}
