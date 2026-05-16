import { randomUUID } from 'crypto';
import path from 'path';
import sharp from 'sharp';
import { MediaRepository, type MediaPurpose } from '../shared/media.repo.js';
import { ALLOWED_MEDIA_MIME_TYPES } from '../shared/media.constants.js';
import {
    MediaFileTooLargeError,
    MediaFilesLimitExceededError,
    UnsupportedMediaTypeError,
} from '../shared/media.errors.js';

export interface UploadedMedia {
    bucket: string;
    objectKey: string;
    mimeType: string;
    size: number;
    originalName: string;
    mediaUrl: string;
    width?: number;
    height?: number;
    optimized?: boolean;
}

export interface UploadPathContext {
    conversationId?: string;
}

export type MediaStorage = Pick<
    MediaRepository,
    "getBucketByPurpose" | "buildMediaUrl" | "putObject"
>;

const ALLOWED_MIME_TYPES = new Set(ALLOWED_MEDIA_MIME_TYPES);

export class MediaService {
    private readonly mediaRepository: MediaStorage;
    private readonly maxFileSize: number;
    private readonly maxFiles: number;
    private readonly profileByPurpose: Record<
        MediaPurpose,
        { maxDimension: number; quality: number }
    >;

    constructor(mediaRepository: MediaStorage = new MediaRepository()) {
        this.mediaRepository = mediaRepository;

        const fromEnv = Number(process.env.MEDIA_MAX_FILE_SIZE || '5242880');
        this.maxFileSize = Number.isNaN(fromEnv) ? 5 * 1024 * 1024 : fromEnv;

        const maxFiles = Number(process.env.MEDIA_MAX_FILES || '10');
        this.maxFiles = Number.isNaN(maxFiles) ? 10 : maxFiles;

        this.profileByPurpose = {
            post: {
                maxDimension: Number(process.env.MEDIA_POST_MAX_DIMENSION || '1920'),
                quality: Number(process.env.MEDIA_POST_QUALITY || '82'),
            },
            message: {
                maxDimension: Number(process.env.MEDIA_MESSAGE_MAX_DIMENSION || '1280'),
                quality: Number(process.env.MEDIA_MESSAGE_QUALITY || '78'),
            },
            avatar: {
                maxDimension: Number(process.env.MEDIA_AVATAR_MAX_DIMENSION || '512'),
                quality: Number(process.env.MEDIA_AVATAR_QUALITY || '80'),
            },
        };
    }

    private sanitizeName(name: string): string {
        return name.replace(/[^a-zA-Z0-9._-]/g, '_');
    }

    private sanitizePathSegment(value: string, fallback: string): string {
        const cleaned = String(value || '')
            .trim()
            .replace(/[^a-zA-Z0-9_-]/g, '');

        return cleaned || fallback;
    }

    private buildDatePath(date = new Date()): string {
        const year = date.getUTCFullYear();
        const month = String(date.getUTCMonth() + 1).padStart(2, '0');
        const day = String(date.getUTCDate()).padStart(2, '0');

        return `${year}/${month}/${day}`;
    }

    private assertValidFile(file: Express.Multer.File): void {
        if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
            throw new UnsupportedMediaTypeError();
        }

        if (file.size > this.maxFileSize) {
            throw new MediaFileTooLargeError();
        }
    }

    private assertValidBatch(files: Express.Multer.File[]): void {
        if (files.length > this.maxFiles) {
            throw new MediaFilesLimitExceededError();
        }
    }

    private buildObjectKey(
        purpose: MediaPurpose,
        ownerId: string,
        originalName: string,
        extension: string,
        context: UploadPathContext,
    ): string {
        const safeOwnerId = this.sanitizePathSegment(ownerId, 'unknown-user');
        const safeExtension = this.sanitizePathSegment(extension.toLowerCase(), 'bin');
        const datePath = this.buildDatePath();
        const objectId = randomUUID();
        const safeName = this.sanitizeName(path.parse(originalName || 'file').name || 'file');

        if (purpose === 'avatar') {
            return `users/${safeOwnerId}/avatar/${datePath}/${objectId}.${safeExtension}`;
        }

        if (purpose === 'message') {
            const safeConversationId = context.conversationId
                ? this.sanitizePathSegment(context.conversationId, 'unknown-conversation')
                : 'unassigned';

            return `conversations/${safeConversationId}/users/${safeOwnerId}/${datePath}/${objectId}_${safeName}.${safeExtension}`;
        }

        return `users/${safeOwnerId}/posts/${datePath}/${objectId}_${safeName}.${safeExtension}`;
    }

    private async optimizeImage(
        file: Express.Multer.File,
        purpose: MediaPurpose,
    ): Promise<{
        buffer: Buffer;
        mimeType: string;
        extension: string;
        width?: number;
        height?: number;
        optimized: boolean;
    }> {
        if (file.mimetype === 'image/gif') {
            return {
                buffer: file.buffer,
                mimeType: file.mimetype,
                extension: 'gif',
                optimized: false,
            };
        }

        const profile = this.profileByPurpose[purpose];

        const transformer = sharp(file.buffer, { failOn: 'none' }).rotate();
        const metadata = await transformer.metadata();

        const resized = transformer.resize({
            width: profile.maxDimension,
            height: profile.maxDimension,
            fit: 'inside',
            withoutEnlargement: true,
        });

        const output = await resized.webp({ quality: profile.quality }).toBuffer();
        const outMeta = await sharp(output).metadata();

        return {
            buffer: output,
            mimeType: 'image/webp',
            extension: 'webp',
            width: outMeta.width || metadata.width,
            height: outMeta.height || metadata.height,
            optimized: true,
        };
    }

    async uploadFiles(
        files: Express.Multer.File[],
        purpose: MediaPurpose,
        ownerId: string,
        context: UploadPathContext = {},
    ): Promise<UploadedMedia[]> {
        const bucket = this.mediaRepository.getBucketByPurpose(purpose);
        this.assertValidBatch(files);

        return Promise.all(
            files.map(async (file) => {
                this.assertValidFile(file);

                const optimized = await this.optimizeImage(file, purpose);
                const objectKey = this.buildObjectKey(
                    purpose,
                    ownerId,
                    file.originalname || 'file',
                    optimized.extension,
                    context,
                );

                await this.mediaRepository.putObject({
                    bucket,
                    objectKey,
                    buffer: optimized.buffer,
                    mimeType: optimized.mimeType,
                });

                return {
                    bucket,
                    objectKey,
                    mimeType: optimized.mimeType,
                    size: optimized.buffer.length,
                    originalName: file.originalname,
                    mediaUrl: this.mediaRepository.buildMediaUrl(bucket, objectKey),
                    width: optimized.width,
                    height: optimized.height,
                    optimized: optimized.optimized,
                };
            }),
        );
    }

    enrichMediaUrl<T extends { bucket: string; objectKey: string }>(
        media: T,
    ): T & { mediaUrl: string } {
        return {
            ...media,
            mediaUrl: this.mediaRepository.buildMediaUrl(media.bucket, media.objectKey),
        };
    }
}
