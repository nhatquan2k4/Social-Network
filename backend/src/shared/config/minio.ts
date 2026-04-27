import { Client } from "minio";
import { envConfig } from "./env";

export type MediaPurpose = "post" | "message" | "avatar";

export const minioConfig = {
	...envConfig.minio,
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

	const buildPublicReadPolicy = (bucket: string): string =>
		JSON.stringify({
			Version: "2012-10-17",
			Statement: [
				{
					Effect: "Allow",
					Principal: { AWS: ["*"] },
					Action: ["s3:GetObject"],
					Resource: [`arn:aws:s3:::${bucket}/*`],
				},
			],
		});

	await Promise.all(
		entries.map(async ([purpose, bucket]) => {
			const exists = await minioClient.bucketExists(bucket);
			if (!exists) {
				await minioClient.makeBucket(bucket, "us-east-1");
			}

			// Public buckets for rendering media directly in clients.
			if (purpose === "post" || purpose === "avatar") {
				await minioClient.setBucketPolicy(bucket, buildPublicReadPolicy(bucket));
			}
		}),
	);
};
