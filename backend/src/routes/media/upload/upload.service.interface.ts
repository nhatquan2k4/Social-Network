import type { MediaRepositoryInterface } from '../shared/media.repo.interface.js';
import type { MediaService } from './upload.service.js';

export type MediaStorage = Pick<
    MediaRepositoryInterface,
    'getBucketByPurpose' | 'buildMediaUrl' | 'putObject'
>;

export interface MediaServiceInterface {
    uploadFiles: MediaService['uploadFiles'];
    enrichMediaUrl: MediaService['enrichMediaUrl'];
}
