import type { UserRepository } from './users.repo.js';

export interface UserRepositoryInterface extends Pick<
    UserRepository,
    | 'findByUsername'
    | 'findByEmail'
    | 'findById'
    | 'findByIdWithoutPassword'
    | 'exists'
    | 'create'
    | 'markEmailVerified'
    | 'setEmailVerificationSentAt'
    | 'findByIdWithFields'
    | 'findProfileById'
    | 'updateProfile'
    | 'updateAvatar'
    | 'searchByDisplayName'
    | 'updateLastSeenAt'
    | 'getLastSeenBatch'
    | 'updatePassword'
> {}
