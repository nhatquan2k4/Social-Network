import assert from "node:assert/strict";
import { afterEach, describe, it } from "node:test";
import {
    MediaFileTooLargeError,
    MediaFilesLimitExceededError,
    UnsupportedMediaTypeError,
} from "../../../src/routes/media/shared/media.errors.js";
import { MediaService } from "../../../src/routes/media/upload/upload.service.js";


interface PutObjectCall {
    bucket: string;
    objectKey: string;
    buffer: Buffer;
    mimeType: string;
}

const originalMaxFileSize = process.env.MEDIA_MAX_FILE_SIZE;
const originalMaxFiles = process.env.MEDIA_MAX_FILES;

class FakeMediaRepository {
    putObjectCalls: PutObjectCall[] = [];

    getBucketByPurpose(purpose: string) {
        return `bucket-${purpose}`;
    }

    buildMediaUrl(bucket: string, objectKey: string) {
        return `https://media.test/${bucket}/${objectKey}`;
    }

    async putObject(input: PutObjectCall) {
        this.putObjectCalls.push(input);
    }
}

const createService = (env: { maxFileSize?: string; maxFiles?: string } = {}) => {
    if (env.maxFileSize !== undefined) {
        process.env.MEDIA_MAX_FILE_SIZE = env.maxFileSize;
    }
    if (env.maxFiles !== undefined) {
        process.env.MEDIA_MAX_FILES = env.maxFiles;
    }

    const repository = new FakeMediaRepository();
    const service = new MediaService(repository);

    return { service, repository };
};

const createFile = (
    overrides: Partial<Express.Multer.File> = {},
): Express.Multer.File => {
    const buffer = overrides.buffer ?? Buffer.from("GIF89a");

    return {
        fieldname: "files",
        originalname: "hello world!.gif",
        encoding: "7bit",
        mimetype: "image/gif",
        size: buffer.length,
        destination: "",
        filename: "",
        path: "",
        buffer,
        stream: undefined as any,
        ...overrides,
    };
};

afterEach(() => {
    if (originalMaxFileSize === undefined) {
        delete process.env.MEDIA_MAX_FILE_SIZE;
    } else {
        process.env.MEDIA_MAX_FILE_SIZE = originalMaxFileSize;
    }

    if (originalMaxFiles === undefined) {
        delete process.env.MEDIA_MAX_FILES;
    } else {
        process.env.MEDIA_MAX_FILES = originalMaxFiles;
    }
});

describe("media service", () => {
    it("rejects unsupported media MIME types before storage", async () => {
        const { service, repository } = createService();

        await assert.rejects(
            () =>
                service.uploadFiles(
                    [createFile({ mimetype: "application/pdf", originalname: "doc.pdf" })],
                    "post",
                    "user-1",
                ),
            UnsupportedMediaTypeError,
        );
        assert.equal(repository.putObjectCalls.length, 0);
    });

    it("rejects files larger than configured max file size", async () => {
        const { service, repository } = createService({ maxFileSize: "3" });

        await assert.rejects(
            () => service.uploadFiles([createFile()], "post", "user-1"),
            MediaFileTooLargeError,
        );
        assert.equal(repository.putObjectCalls.length, 0);
    });

    it("rejects batches larger than configured max files", async () => {
        const { service, repository } = createService({ maxFiles: "1" });

        await assert.rejects(
            () => service.uploadFiles([createFile(), createFile()], "post", "user-1"),
            MediaFilesLimitExceededError,
        );
        assert.equal(repository.putObjectCalls.length, 0);
    });

    it("normalizes uploaded media output and stores a post object key without MinIO", async () => {
        const { service, repository } = createService();

        const [uploaded] = await service.uploadFiles(
            [createFile({ originalname: "My Post Image!.gif" })],
            "post",
            " user id ! ",
        );

        assert.equal(uploaded.bucket, "bucket-post");
        assert.equal(uploaded.mimeType, "image/gif");
        assert.equal(uploaded.size, 6);
        assert.equal(uploaded.originalName, "My Post Image!.gif");
        assert.equal(uploaded.optimized, false);
        assert.match(
            uploaded.objectKey,
            /^users\/userid\/posts\/\d{4}\/\d{2}\/\d{2}\/[0-9a-f-]+_My_Post_Image_\.gif$/,
        );
        assert.equal(
            uploaded.mediaUrl,
            `https://media.test/bucket-post/${uploaded.objectKey}`,
        );

        assert.equal(repository.putObjectCalls.length, 1);
        assert.equal(repository.putObjectCalls[0].bucket, "bucket-post");
        assert.equal(repository.putObjectCalls[0].objectKey, uploaded.objectKey);
        assert.equal(repository.putObjectCalls[0].mimeType, "image/gif");
    });

    it("builds message media paths with sanitized conversation and owner segments", async () => {
        const { service } = createService();

        const [uploaded] = await service.uploadFiles(
            [createFile({ originalname: "chat image.gif" })],
            "message",
            " user id ! ",
            { conversationId: " conversation id ! " },
        );

        assert.equal(uploaded.bucket, "bucket-message");
        assert.match(
            uploaded.objectKey,
            /^conversations\/conversationid\/users\/userid\/\d{4}\/\d{2}\/\d{2}\/[0-9a-f-]+_chat_image\.gif$/,
        );
    });

    it("builds avatar paths without preserving original filename", async () => {
        const { service } = createService();

        const [uploaded] = await service.uploadFiles(
            [createFile({ originalname: "avatar upload.gif" })],
            "avatar",
            "",
        );

        assert.equal(uploaded.bucket, "bucket-avatar");
        assert.match(
            uploaded.objectKey,
            /^users\/unknown-user\/avatar\/\d{4}\/\d{2}\/\d{2}\/[0-9a-f-]+\.gif$/,
        );
    });

    it("enriches existing media with a repository media URL", () => {
        const { service } = createService();

        assert.deepEqual(
            service.enrichMediaUrl({
                bucket: "bucket-post",
                objectKey: "users/user-1/posts/file.webp",
            }),
            {
                bucket: "bucket-post",
                objectKey: "users/user-1/posts/file.webp",
                mediaUrl: "https://media.test/bucket-post/users/user-1/posts/file.webp",
            },
        );
    });
});
