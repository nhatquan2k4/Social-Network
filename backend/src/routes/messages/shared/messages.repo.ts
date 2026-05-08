import { MessageModel as Message } from "./messages.model.js";
import { Types } from "mongoose";

export class MessageRepository {
    async create(messageData: {
        conversationId: Types.ObjectId;
        senderId: Types.ObjectId;
        content?: string;
        media?: Array<{
            bucket: string;
            objectKey: string;
            mimeType: string;
            size: number;
        }>;
    }) {
        return await Message.create(messageData);
    }

    async findByConversationId(
        conversationId: string,
        options: {
            limit: number;
            cursor?: {
                createdAt: Date;
                id: Types.ObjectId;
            };
        },
    ) {
        const query: Record<string, unknown> = {
            conversationId,
        };

        if (options.cursor) {
            query.$or = [
                {
                    createdAt: {
                        $lt: options.cursor.createdAt,
                    },
                },
                {
                    createdAt: options.cursor.createdAt,
                    _id: {
                        $lt: options.cursor.id,
                    },
                },
            ];
        }

        return await Message.find(query)
            .sort({ createdAt: -1, _id: -1 })
            .limit(options.limit);
    }

    async findByIdAndConversationId(messageId: string, conversationId: string) {
        return await Message.findOne({ _id: messageId, conversationId });
    }

    async findById(messageId: string) {
        return await Message.findById(messageId);
    }

    async findLatestByConversationId(conversationId: string) {
        return await Message.findOne({ conversationId }).sort({ createdAt: -1, _id: -1 });
    }

    async deleteByIdAndConversationId(messageId: string, conversationId: string) {
        return await Message.findOneAndDelete({ _id: messageId, conversationId });
    }

    async upsertReaction(
        messageId: string,
        conversationId: string,
        userId: Types.ObjectId,
        emoji: string,
    ) {
        return await Message.findOneAndUpdate(
            { _id: messageId, conversationId },
            [
                {
                    $set: {
                        reactions: {
                            $concatArrays: [
                                {
                                    $filter: {
                                        input: { $ifNull: ["$reactions", []] },
                                        as: "reaction",
                                        cond: { $ne: ["$$reaction.userId", userId] },
                                    },
                                },
                                [
                                    {
                                        userId,
                                        emoji,
                                        reactedAt: new Date(),
                                    },
                                ],
                            ],
                        },
                    },
                },
            ],
            { new: true },
        );
    }

    async removeReaction(messageId: string, conversationId: string, userId: Types.ObjectId) {
        return await Message.findOneAndUpdate(
            { _id: messageId, conversationId },
            [
                {
                    $set: {
                        reactions: {
                            $filter: {
                                input: { $ifNull: ["$reactions", []] },
                                as: "reaction",
                                cond: { $ne: ["$$reaction.userId", userId] },
                            },
                        },
                    },
                },
            ],
            { new: true },
        );
    }

    async markAsRead(messageId: string, conversationId: string, userId: Types.ObjectId) {
        return await Message.findOneAndUpdate(
            { _id: messageId, conversationId },
            [
                {
                    $set: {
                        readBy: {
                            $concatArrays: [
                                {
                                    $filter: {
                                        input: { $ifNull: ["$readBy", []] },
                                        as: "reader",
                                        cond: { $ne: ["$$reader.userId", userId] },
                                    },
                                },
                                [
                                    {
                                        userId,
                                        readAt: new Date(),
                                    },
                                ],
                            ],
                        },
                    },
                },
            ],
            { new: true },
        );
    }

    async markAllAsReadByConversation(
        conversationId: string,
        userId: Types.ObjectId,
        readUntil?: Date,
    ) {
        const query: Record<string, unknown> = {
            conversationId,
            senderId: { $ne: userId },
        };

        if (readUntil) {
            query.createdAt = { $lte: readUntil };
        }

        return await Message.updateMany(
            query,
            [
                {
                    $set: {
                        readBy: {
                            $concatArrays: [
                                {
                                    $filter: {
                                        input: { $ifNull: ["$readBy", []] },
                                        as: "reader",
                                        cond: { $ne: ["$$reader.userId", userId] },
                                    },
                                },
                                [
                                    {
                                        userId,
                                        readAt: new Date(),
                                    },
                                ],
                            ],
                        },
                    },
                },
            ],
        );
    }

    async deleteByConversationId(conversationId: string) {
        return await Message.deleteMany({ conversationId });
    }
}
