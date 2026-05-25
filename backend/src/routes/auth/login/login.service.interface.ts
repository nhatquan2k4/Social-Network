import type {
    SessionRepositoryInterface,
} from '../shared/auth.repo.interface.js';
import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { LoginService } from './login.service.js';

export type LoginUserRepository = Pick<UserRepositoryInterface, 'findByUsername'>;
export type LoginSessionRepository = Pick<SessionRepositoryInterface, 'create'>;

export interface LoginServiceDependencies {
    userRepository?: LoginUserRepository;
    sessionRepository?: LoginSessionRepository;
}

export interface LoginServiceInterface {
    execute: LoginService['execute'];
}
