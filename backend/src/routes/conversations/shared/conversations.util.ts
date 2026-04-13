import { Types } from "mongoose";
import { buildMediaUrl } from "../../../shared/config/minio";

interface PopulatedUser {
    _id: Types.ObjectId;
    displayName: string;
    avatarUrl?: string;
}

export const mapConversationParticipants = (participants: any[] = []) => {
    return participants.map((participant: any) => {
        const user = participant.userId as PopulatedUser;
        return {
            _id: user?._id,
            displayName: user?.displayName,
            avatarUrl: user?.avatarUrl ?? null,
            joinedAt: participant.joinedAt,
        };
    });
};

export const enrichMessageMedia = (message: any) => {
    const plain = typeof message?.toObject === "function" ? message.toObject() : message;

    const media = (plain?.media || []).map((item: any) => ({
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
