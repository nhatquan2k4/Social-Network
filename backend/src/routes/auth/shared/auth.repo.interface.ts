import type {
    EmailVerificationTokenRepository,
    SessionRepository,
} from './auth.repo.js';

export interface SessionRepositoryInterface extends Pick<
    SessionRepository,
    'create' | 'deleteByRefreshToken' | 'findByRefreshToken'
> {}

export interface EmailVerificationTokenRepositoryInterface extends Pick<
    EmailVerificationTokenRepository,
    | 'create'
    | 'findValidByHash'
    | 'consumeById'
    | 'consumeAllActiveByUserId'
> {}
