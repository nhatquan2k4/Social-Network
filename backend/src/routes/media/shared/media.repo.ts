import {
    buildMediaUrl,
    getBucketByPurpose,
    minioClient,
} from '../../../shared/config/minio.js';
import type { MediaPurpose } from '../../../shared/config/minio.js';
import type { MediaRepositoryInterface } from './media.repo.interface.js';

interface PutObjectInput {
    bucket: string;
    objectKey: string;
    buffer: Buffer;
    mimeType: string;
}

export class MediaRepository implements MediaRepositoryInterface {
    getBucketByPurpose(purpose: MediaPurpose): string {
        return getBucketByPurpose(purpose);
    }

    buildMediaUrl(bucket: string, objectKey: string): string {
        return buildMediaUrl(bucket, objectKey);
    }

    async putObject(input: PutObjectInput): Promise<void> {
        if (
            process.env.E2E_EXTERNAL_SERVICES === 'mock' ||
            process.env.NODE_ENV === 'test' ||
            process.env.IS_E2E === 'true'
        ) {
            return;
        }

        await minioClient.putObject(
            input.bucket,
            input.objectKey,
            input.buffer,
            input.buffer.length,
            {
                'Content-Type': input.mimeType,
            },
        );
    }
}

export type { MediaPurpose };

export {
    minioClient,
    ensureMediaBuckets,
    buildMediaUrl,
    getBucketByPurpose,
    minioConfig,
} from '../../../shared/config/minio.js';
