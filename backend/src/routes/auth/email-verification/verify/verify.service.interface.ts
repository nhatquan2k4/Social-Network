import type {
    EmailVerificationTokenRepositoryInterface,
} from '../../shared/auth.repo.interface.js';
import type { UserRepositoryInterface } from '../../../users/shared/users.repo.interface.js';
import type { VerifyEmailService } from './verify.service.js';

export type VerifyEmailUserRepository = Pick<
    UserRepositoryInterface,
    'findById' | 'markEmailVerified'
>;
export type VerifyEmailTokenRepository = Pick<
    EmailVerificationTokenRepositoryInterface,
    'findValidByHash' | 'consumeById' | 'consumeAllActiveByUserId'
>;

export interface VerifyEmailServiceDependencies {
    userRepository?: VerifyEmailUserRepository;
    emailVerificationTokenRepository?: VerifyEmailTokenRepository;
}

export interface VerifyEmailServiceInterface {
    execute: VerifyEmailService['execute'];
}
