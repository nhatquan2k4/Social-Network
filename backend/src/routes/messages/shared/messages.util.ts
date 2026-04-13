import { Request } from "express";
import { buildMediaUrl } from "../../../shared/config/minio";
import { MediaService } from "../../media/upload/upload.service";

interface MessageMediaInput {
    bucket: string;
    objectKey: string;
    mimeType: string;
    size: number;
}

const mediaService = new MediaService();

export const sanitizeMedia = (media?: MessageMediaInput[]) => {
    if (!Array.isArray(media) || media.length === 0) {
        return undefined;
    }

    const cleaned = media
        .filter((item: any) => item && typeof item === "object")
        .map((item: any) => ({
            bucket: typeof item.bucket === "string" ? item.bucket.trim() : "",
            objectKey: typeof item.objectKey === "string" ? item.objectKey.trim() : "",
            mimeType: typeof item.mimeType === "string" ? item.mimeType.trim() : "",
            size: Number(item.size),
        }))
        .filter(
            (item) =>
                item.bucket &&
                item.objectKey &&
                item.mimeType &&
                Number.isFinite(item.size) &&
                item.size > 0,
        );

    return cleaned.length > 0 ? cleaned : undefined;
};

export const enrichMessageMedia = (message: any) => {
    const plain = typeof message?.toObject === "function" ? message.toObject() : message;

    const media = (plain?.media || []).map((item: MessageMediaInput) => ({
        ...item,
        mediaUrl: buildMediaUrl(item.bucket, item.objectKey),
    }));

    if (media.length > 0) {
        return {
            ...plain,
            media,
        };
    }

    if (plain?.imgUrl) {
        return {
            ...plain,
            media: [
                {
                    bucket: "",
                    objectKey: "",
                    mimeType: "image/*",
                    size: 0,
                    mediaUrl: plain.imgUrl,
                },
            ],
        };
    }

    return plain;
};

export const parseManualMedia = (raw: any) => {
    if (!raw) {
        return [];
    }

    let value = raw;
    if (typeof raw === "string") {
        try {
            value = JSON.parse(raw);
        } catch {
            return [];
        }
    }

    if (!Array.isArray(value)) {
        return [];
    }

    return value
        .filter((item: any) => item && typeof item === "object")
        .map((item: any) => ({
            bucket: typeof item.bucket === "string" ? item.bucket.trim() : "",
            objectKey: typeof item.objectKey === "string" ? item.objectKey.trim() : "",
            mimeType: typeof item.mimeType === "string" ? item.mimeType.trim() : "",
            size: Number(item.size),
        }))
        .filter(
            (item: any) =>
                item.bucket &&
                item.objectKey &&
                item.mimeType &&
                Number.isFinite(item.size) &&
                item.size > 0,
        );
};

export const mergeMediaFromRequest = async (
    req: Request,
    ownerId: string,
    conversationId?: string,
) => {
    const files = (req.files || []) as Express.Multer.File[];
    const uploadedMedia =
        files.length > 0
            ? await mediaService.uploadFiles(files, "message", ownerId, { conversationId })
            : [];

    const normalizedUploaded = uploadedMedia.map((item) => ({
        bucket: item.bucket,
        objectKey: item.objectKey,
        mimeType: item.mimeType,
        size: item.size,
    }));

    const manualMedia = parseManualMedia(req.body?.media);
    return [...manualMedia, ...normalizedUploaded];
};
