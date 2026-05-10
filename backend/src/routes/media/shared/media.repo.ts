import {
    buildMediaUrl,
    getBucketByPurpose,
    minioClient,
} from '../../../shared/config/minio.js';
import type { MediaPurpose } from '../../../shared/config/minio.js';

interface PutObjectInput {
    bucket: string;
    objectKey: string;
    buffer: Buffer;
    mimeType: string;
}

export class MediaRepository {
    getBucketByPurpose(purpose: MediaPurpose): string {
        return getBucketByPurpose(purpose);
    }

    buildMediaUrl(bucket: string, objectKey: string): string {
        return buildMediaUrl(bucket, objectKey);
    }

    async putObject(input: PutObjectInput): Promise<void> {
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
