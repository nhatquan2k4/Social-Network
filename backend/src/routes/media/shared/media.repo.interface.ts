import type { MediaRepository } from './media.repo.js';

export interface MediaRepositoryInterface extends Pick<
    MediaRepository,
    'getBucketByPurpose' | 'buildMediaUrl' | 'putObject'
> {}
