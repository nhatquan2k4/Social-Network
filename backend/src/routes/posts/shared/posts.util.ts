import { Request } from "express";
import { buildMediaUrl } from "../../../shared/config/minio.js";

export interface PostDocumentLike {
    _id: any;
    authorId: any;
    content?: string;
    media?: Array<{ bucket: string; objectKey: string; mimeType: string; size: number }>;
    likes?: any[];
    comments?: Array<{
        _id: any;
        authorId: any;
        content: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
    commentsCount?: number;
    createdAt: Date;
    updatedAt: Date;
}

export interface PostCommentLike {
    _id: any;
    parentCommentId?: any;
    authorId: any;
    content: string;
    createdAt: Date;
    updatedAt: Date;
}

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

export const normalizeUploadedMedia = (uploadedMedia: any[] = []) => {
    return uploadedMedia.map((item) => ({
        bucket: item.bucket,
        objectKey: item.objectKey,
        mimeType: item.mimeType,
        size: item.size,
    }));
};

export const formatPost = (post: PostDocumentLike) => {
    const media = (post.media || []).map((item) => ({
        ...item,
        mediaUrl: buildMediaUrl(item.bucket, item.objectKey),
    }));

    return {
        ...post,
        media,
        likesCount: post.likes?.length || 0,
    };
};

export const formatComment = (comment: PostCommentLike) => {
    return {
        _id: comment._id,
        parentCommentId: comment.parentCommentId || null,
        authorId: comment.authorId,
        content: comment.content,
        createdAt: comment.createdAt,
        updatedAt: comment.updatedAt,
    };
};

export const buildCommentTree = (comments: any[]) => {
    const map = new Map<string, any>();
    const roots: any[] = [];

    comments.forEach((comment) => {
        map.set(comment._id.toString(), {
            ...comment,
            children: [],
        });
    });

    comments.forEach((comment) => {
        const node = map.get(comment._id.toString());
        const parentId = comment.parentCommentId ? comment.parentCommentId.toString() : null;

        if (!parentId) {
            roots.push(node);
            return;
        }

        const parentNode = map.get(parentId);
        if (!parentNode) {
            roots.push(node);
            return;
        }

        parentNode.children.push(node);
    });

    return roots;
};

export const collectDescendantCommentIds = (comments: any[], rootCommentId: string) => {
    const childrenByParent = new Map<string, string[]>();

    comments.forEach((comment) => {
        const parentId = comment.parentCommentId ? comment.parentCommentId.toString() : null;
        if (!parentId) {
            return;
        }

        if (!childrenByParent.has(parentId)) {
            childrenByParent.set(parentId, []);
        }
        childrenByParent.get(parentId)!.push(comment._id.toString());
    });

    const toDelete = new Set<string>([rootCommentId]);
    const queue = [rootCommentId];

    while (queue.length > 0) {
        const currentId = queue.shift() as string;
        const children = childrenByParent.get(currentId) || [];
        children.forEach((childId) => {
            if (!toDelete.has(childId)) {
                toDelete.add(childId);
                queue.push(childId);
            }
        });
    }

    return toDelete;
};
