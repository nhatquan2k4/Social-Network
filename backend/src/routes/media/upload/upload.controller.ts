import { Request, Response } from 'express';
import { type MediaPurpose } from '../shared/media.repo.js';
import { MediaService } from './upload.service.js';
import { MEDIA_PURPOSES } from '../shared/media.constants.js';
import {
    MediaFileTooLargeError,
    MediaFilesLimitExceededError,
    UnsupportedMediaTypeError,
} from '../shared/media.errors.js';

const mediaService = new MediaService();

export const uploadMedia = async (req: Request, res: Response) => {
    try {
        const purpose = (req.body?.purpose || req.query?.purpose || 'post') as MediaPurpose;
        const conversationIdRaw = req.body?.conversationId || req.query?.conversationId;
        const conversationId =
            typeof conversationIdRaw === 'string' ? conversationIdRaw.trim() : '';
        const requireConversationIdForMessage =
            process.env.MEDIA_MESSAGE_REQUIRE_CONVERSATION_ID !== 'false';

        if (!MEDIA_PURPOSES.includes(purpose)) {
            return res.status(400).json({ message: 'purpose khong hop le' });
        }

        const files = (req.files || []) as Express.Multer.File[];

        if (!files.length) {
            return res.status(400).json({ message: 'Khong tim thay file upload' });
        }

        const ownerId = req.user!._id.toString();

        if (purpose === 'message' && requireConversationIdForMessage && !conversationId) {
            return res
                .status(400)
                .json({ message: 'conversationId la bat buoc voi purpose=message' });
        }

        const uploaded = await mediaService.uploadFiles(
            files,
            purpose,
            ownerId,
            purpose === 'message' ? { conversationId: conversationId || undefined } : {},
        );

        return res.status(201).json({
            message: 'Upload media thanh cong',
            data: uploaded,
        });
    } catch (error: any) {
        console.error('Loi upload media', error);
        if (
            error instanceof UnsupportedMediaTypeError ||
            error instanceof MediaFileTooLargeError ||
            error instanceof MediaFilesLimitExceededError
        ) {
            return res.status(400).json({ message: error.message });
        }

        return res.status(500).json({ message: 'Loi server' });
    }
};
