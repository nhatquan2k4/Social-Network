import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { ForgotPasswordService } from './forgot-password.service.js';

export type ForgotPasswordUserRepository = Pick<
    UserRepositoryInterface,
    'findByEmail' | 'updatePassword'
>;

export interface ForgotPasswordServiceDependencies {
    userRepository?: ForgotPasswordUserRepository;
}

export interface ForgotPasswordServiceInterface {
    execute: ForgotPasswordService['execute'];
}
