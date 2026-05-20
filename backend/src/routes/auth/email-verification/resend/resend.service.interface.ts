import type {
    EmailVerificationTokenRepositoryInterface,
} from '../../shared/auth.repo.interface.js';
import type { UserRepositoryInterface } from '../../../users/shared/users.repo.interface.js';
import type { ResendEmailVerificationService } from './resend.service.js';

export type ResendEmailVerificationUserRepository = Pick<
    UserRepositoryInterface,
    'findByEmail' | 'setEmailVerificationSentAt'
>;
export type ResendEmailVerificationTokenRepository = Pick<
    EmailVerificationTokenRepositoryInterface,
    'consumeAllActiveByUserId' | 'create'
>;

export interface ResendEmailVerificationServiceDependencies {
    userRepository?: ResendEmailVerificationUserRepository;
    emailVerificationTokenRepository?: ResendEmailVerificationTokenRepository;
}

export interface ResendEmailVerificationServiceInterface {
    execute: ResendEmailVerificationService['execute'];
}
