import { randomUUID } from "crypto";
import path from "path";
import sharp from "sharp";
import { buildMediaUrl, getBucketByPurpose, MediaPurpose, minioClient } from "../config/minio";

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

const ALLOWED_MIME_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
]);

export class MediaService {
  private readonly maxFileSize: number;
  private readonly maxFiles: number;
  private readonly profileByPurpose: Record<MediaPurpose, { maxDimension: number; quality: number }>;

  constructor() {
    const fromEnv = Number(process.env.MEDIA_MAX_FILE_SIZE || "5242880");
    this.maxFileSize = Number.isNaN(fromEnv) ? 5 * 1024 * 1024 : fromEnv;

    const maxFiles = Number(process.env.MEDIA_MAX_FILES || "10");
    this.maxFiles = Number.isNaN(maxFiles) ? 10 : maxFiles;

    this.profileByPurpose = {
      post: {
        maxDimension: Number(process.env.MEDIA_POST_MAX_DIMENSION || "1920"),
        quality: Number(process.env.MEDIA_POST_QUALITY || "82"),
      },
      message: {
        maxDimension: Number(process.env.MEDIA_MESSAGE_MAX_DIMENSION || "1280"),
        quality: Number(process.env.MEDIA_MESSAGE_QUALITY || "78"),
      },
      avatar: {
        maxDimension: Number(process.env.MEDIA_AVATAR_MAX_DIMENSION || "512"),
        quality: Number(process.env.MEDIA_AVATAR_QUALITY || "80"),
      },
    };
  }

  private sanitizeName(name: string): string {
    return name.replace(/[^a-zA-Z0-9._-]/g, "_");
  }

  private assertValidFile(file: Express.Multer.File): void {
    if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
      throw new Error("Dinh dang file khong duoc ho tro");
    }

    if (file.size > this.maxFileSize) {
      throw new Error("Kich thuoc file vuot qua gioi han");
    }
  }

  private assertValidBatch(files: Express.Multer.File[]): void {
    if (files.length > this.maxFiles) {
      throw new Error("So luong file vuot qua gioi han");
    }
  }

  private buildObjectKey(purpose: MediaPurpose, ownerId: string, originalName: string, extension: string): string {
    const safeName = this.sanitizeName(path.parse(originalName || "file").name || "file");
    return `${purpose}/${ownerId}/${randomUUID()}_${safeName}.${extension}`;
  }

  private async optimizeImage(
    file: Express.Multer.File,
    purpose: MediaPurpose,
  ): Promise<{ buffer: Buffer; mimeType: string; extension: string; width?: number; height?: number; optimized: boolean }> {
    // Keep GIF as-is to preserve animation.
    if (file.mimetype === "image/gif") {
      return {
        buffer: file.buffer,
        mimeType: file.mimetype,
        extension: "gif",
        optimized: false,
      };
    }

    const profile = this.profileByPurpose[purpose];

    const transformer = sharp(file.buffer, { failOn: "none" }).rotate();
    const metadata = await transformer.metadata();

    const resized = transformer.resize({
      width: profile.maxDimension,
      height: profile.maxDimension,
      fit: "inside",
      withoutEnlargement: true,
    });

    const output = await resized.webp({ quality: profile.quality }).toBuffer();
    const outMeta = await sharp(output).metadata();

    return {
      buffer: output,
      mimeType: "image/webp",
      extension: "webp",
      width: outMeta.width || metadata.width,
      height: outMeta.height || metadata.height,
      optimized: true,
    };
  }

  async uploadFiles(
    files: Express.Multer.File[],
    purpose: MediaPurpose,
    ownerId: string,
  ): Promise<UploadedMedia[]> {
    const bucket = getBucketByPurpose(purpose);
    this.assertValidBatch(files);

    return Promise.all(
      files.map(async (file) => {
        this.assertValidFile(file);

        const optimized = await this.optimizeImage(file, purpose);
        const objectKey = this.buildObjectKey(
          purpose,
          ownerId,
          file.originalname || "file",
          optimized.extension,
        );

        await minioClient.putObject(bucket, objectKey, optimized.buffer, optimized.buffer.length, {
          "Content-Type": optimized.mimeType,
        });

        return {
          bucket,
          objectKey,
          mimeType: optimized.mimeType,
          size: optimized.buffer.length,
          originalName: file.originalname,
          mediaUrl: buildMediaUrl(bucket, objectKey),
          width: optimized.width,
          height: optimized.height,
          optimized: optimized.optimized,
        };
      }),
    );
  }

  enrichMediaUrl<T extends { bucket: string; objectKey: string }>(media: T): T & { mediaUrl: string } {
    return {
      ...media,
      mediaUrl: buildMediaUrl(media.bucket, media.objectKey),
    };
  }
}
