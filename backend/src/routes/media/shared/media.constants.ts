import { type MediaPurpose } from './media.repo.js';

export const MEDIA_PURPOSES: MediaPurpose[] = ['post', 'message', 'avatar'];

export const ALLOWED_MEDIA_MIME_TYPES = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
];

export const MEDIA_ERROR_MESSAGES = {
    UNSUPPORTED_FILE_TYPE: 'Dinh dang file khong duoc ho tro',
    FILE_TOO_LARGE: 'Kich thuoc file vuot qua gioi han',
    TOO_MANY_FILES: 'So luong file vuot qua gioi han',
} as const;
