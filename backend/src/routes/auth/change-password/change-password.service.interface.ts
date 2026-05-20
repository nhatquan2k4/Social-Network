import type { UserRepositoryInterface } from '../../users/shared/users.repo.interface.js';
import type { ChangePasswordService } from './change-password.service.js';

export type ChangePasswordUserRepository = Pick<
    UserRepositoryInterface,
    'findById' | 'updatePassword'
>;

export interface ChangePasswordServiceDependencies {
    userRepository?: ChangePasswordUserRepository;
}

export interface ChangePasswordServiceInterface {
    execute: ChangePasswordService['execute'];
}
