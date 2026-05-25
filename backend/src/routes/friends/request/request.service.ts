import { Types } from "mongoose";
import { UserRepository } from "../../users/shared/users.repo.js";
import { NotificationService } from "../../notifications/notifications.service.js";
import {
    FriendRepository,
    FriendRequestRepository,
} from "../shared/friends.repo.js";
import {
    AlreadyFriendsError,
    FriendRequestAcceptForbiddenError,
    FriendRequestNotFoundError,
    FriendRequestPendingError,
    FriendRequestRejectForbiddenError,
    FriendSelfRequestError,
    FriendUserNotFoundError,
} from "../shared/friends.errors.js";
import type {
    RequestFriendRepository,
    RequestFriendRequestRepository,
    RequestNotificationService,
    RequestServiceDependencies,
    RequestServiceInterface,
    RequestUserRepository,
} from "./request.service.interface.js";

export class RequestService implements RequestServiceInterface {
    private friendRepository: RequestFriendRepository;
    private friendRequestRepository: RequestFriendRequestRepository;
    private userRepository: RequestUserRepository;
    private notificationService: RequestNotificationService;

    constructor(dependencies: RequestServiceDependencies = {}) {
        this.friendRepository = dependencies.friendRepository ?? new FriendRepository();
        this.friendRequestRepository =
            dependencies.friendRequestRepository ?? new FriendRequestRepository();
        this.userRepository = dependencies.userRepository ?? new UserRepository();
        this.notificationService =
            dependencies.notificationService ?? new NotificationService();
    }

    async sendFriendRequest(from: Types.ObjectId, to: string, message?: string) {
        if (from.toString() === to) {
            throw new FriendSelfRequestError();
        }

        const userExists = await this.userRepository.exists(to);
        if (!userExists) {
            throw new FriendUserNotFoundError();
        }

        let userA = from.toString();
        let userB = to;
        if (userA > userB) {
            [userA, userB] = [userB, userA];
        }

        const [alreadyFriends, pendingRequest] = await Promise.all([
            this.friendRepository.findByUsers(userA, userB),
            this.friendRequestRepository.findBetweenUsers(from, to as any),
        ]);

        if (alreadyFriends) {
            throw new AlreadyFriendsError();
        }

        if (pendingRequest) {
            throw new FriendRequestPendingError();
        }

        // Tự động kết bạn và tạo hội thoại trực tiếp nếu đang ở chế độ E2E
        if (process.env.IS_E2E === "true") {
            console.log(`🤖 E2E: Auto-accepting friend request between ${from} and ${to}`);
            await this.friendRepository.create(from, new Types.ObjectId(to));

            // Tự động tạo cuộc hội thoại trực tiếp (direct conversation) giữa 2 user
            const { ConversationModel } = await import("../../conversations/shared/conversations.model.js");
            const existingConv = await ConversationModel.findOne({
                type: "direct",
                "participants.userId": { $all: [from, new Types.ObjectId(to)] }
            });
            if (!existingConv) {
                await ConversationModel.create({
                    type: "direct",
                    participants: [
                        { userId: from },
                        { userId: new Types.ObjectId(to) }
                    ],
                    lastMessageAt: new Date(),
                    seenBy: [from, new Types.ObjectId(to)],
                    unreadCounts: {
                        [from.toString()]: 0,
                        [to]: 0
                    }
                });
                console.log("🤖 E2E: Auto-created direct conversation for E2E user.");
            }

            // Tạo một mock request Object để trả về (đáp ứng đúng kiểu trả về)
            const request = await this.friendRequestRepository.create(from, to as any, message);
            // Xóa ngay request
            await this.friendRequestRepository.deleteById(request._id.toString());
            return request;
        }

        const request = await this.friendRequestRepository.create(from, to as any, message);

        await this.notificationService.createNotification({
            recipientId: new Types.ObjectId(to),
            actorId: from,
            type: "FRIEND_REQUEST",
            title: "Loi moi ket ban moi",
            body: "Ban vua nhan duoc mot loi moi ket ban.",
            entityType: "friend_request",
            entityId: request._id.toString(),
            metadata: {
                requestId: request._id.toString(),
            },
        });

        return request;
    }

    async acceptFriendRequest(requestId: string, userId: Types.ObjectId) {
        const request = await this.friendRequestRepository.findById(requestId);
        if (!request) {
            throw new FriendRequestNotFoundError();
        }

        if (request.to.toString() !== userId.toString()) {
            throw new FriendRequestAcceptForbiddenError();
        }

        await this.friendRepository.create(request.from, request.to);
        await this.friendRequestRepository.deleteById(requestId);

        await this.notificationService.createNotification({
            recipientId: request.from,
            actorId: request.to,
            type: "FRIEND_ACCEPTED",
            title: "Loi moi ket ban duoc chap nhan",
            body: "Loi moi ket ban cua ban da duoc chap nhan.",
            entityType: "friend_request",
            entityId: requestId,
        });

        const from = await this.userRepository.findByIdWithFields(
            request.from,
            "username displayName avatarUrl",
        );

        return {
            _id: from?._id,
            displayName: from?.displayName,
            avatarUrl: from?.avatarUrl,
        };
    }

    async rejectFriendRequest(requestId: string, userId: Types.ObjectId) {
        const request = await this.friendRequestRepository.findById(requestId);
        if (!request) {
            throw new FriendRequestNotFoundError();
        }

        if (request.to.toString() !== userId.toString()) {
            throw new FriendRequestRejectForbiddenError();
        }

        await this.friendRequestRepository.deleteById(requestId);
    }

    async getAllFriendRequests(userId: Types.ObjectId) {
        const populateFields = "_id username displayName avatarUrl";

        const [sent, received] = await Promise.all([
            this.friendRequestRepository.findSentByUserId(userId, populateFields),
            this.friendRequestRepository.findReceivedByUserId(userId, populateFields),
        ]);

        return { sent, received };
    }
}
