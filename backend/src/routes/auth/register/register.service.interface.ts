import type {
    EmailVerificationTokenRepositoryInterface,
} from '../shared/auth.repo.interface.js';
import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { RegisterService } from './register.service.js';

export type RegisterUserRepository = Pick<
    UserRepositoryInterface,
    'findByUsername' | 'findByEmail' | 'create' | 'setEmailVerificationSentAt'
>;
export type RegisterEmailVerificationTokenRepository = Pick<
    EmailVerificationTokenRepositoryInterface,
    'consumeAllActiveByUserId' | 'create'
>;

export interface RegisterServiceDependencies {
    userRepository?: RegisterUserRepository;
    emailVerificationTokenRepository?: RegisterEmailVerificationTokenRepository;
}

export interface RegisterServiceInterface {
    execute: RegisterService['execute'];
}
