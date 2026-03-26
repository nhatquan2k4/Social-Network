import { Client } from "minio";

export type MediaPurpose = "post" | "message" | "avatar";

const minioPort = Number(process.env.MINIO_PORT || "9000");

export const minioConfig = {
  endPoint: process.env.MINIO_ENDPOINT || "localhost",
  port: Number.isNaN(minioPort) ? 9000 : minioPort,
  useSSL: process.env.MINIO_USE_SSL === "true",
  accessKey: process.env.MINIO_ACCESS_KEY || "minioadmin",
  secretKey: process.env.MINIO_SECRET_KEY || "minioadmin",
  publicBaseUrl: process.env.MINIO_PUBLIC_BASE_URL || "http://localhost:9000",
  buckets: {
    post: process.env.MINIO_BUCKET_POSTS || "social-posts",
    message: process.env.MINIO_BUCKET_MESSAGES || "social-messages",
    avatar: process.env.MINIO_BUCKET_AVATARS || "social-avatars",
  },
};

export const minioClient = new Client({
  endPoint: minioConfig.endPoint,
  port: minioConfig.port,
  useSSL: minioConfig.useSSL,
  accessKey: minioConfig.accessKey,
  secretKey: minioConfig.secretKey,
});

export const getBucketByPurpose = (purpose: MediaPurpose): string => {
  return minioConfig.buckets[purpose];
};

export const buildMediaUrl = (bucket: string, objectKey: string): string => {
  const base = minioConfig.publicBaseUrl.replace(/\/$/, "");
  return `${base}/${bucket}/${objectKey}`;
};

export const ensureMediaBuckets = async (): Promise<void> => {
  const entries = Object.entries(minioConfig.buckets);

  await Promise.all(
    entries.map(async ([, bucket]) => {
      const exists = await minioClient.bucketExists(bucket);
      if (!exists) {
        await minioClient.makeBucket(bucket, "us-east-1");
      }
    }),
  );
};
