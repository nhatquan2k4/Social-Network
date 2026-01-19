import { FriendRepository } from '../repositories/friendRepository';
import { FriendRequestRepository } from '../repositories/friendRequestRepository';
import { UserRepository } from '../repositories/userRepository';
import { Types } from 'mongoose';

export class FriendService {
    private friendRepository: FriendRepository;
    private friendRequestRepository: FriendRequestRepository;
    private userRepository: UserRepository;

    constructor() {
        this.friendRepository = new FriendRepository();
        this.friendRequestRepository = new FriendRequestRepository();
        this.userRepository = new UserRepository();
    }

    async sendFriendRequest(from: Types.ObjectId, to: string, message?: string) {
        // Khong the gui cho chinh minh
        if (from.toString() === to) {
            throw new Error('Khong the gui loi moi ket ban voi chinh ban than');
        }

        // Kiem tra user ton tai
        const userExists = await this.userRepository.exists(to);
        if (!userExists) {
            throw new Error('Nguoi dung khong ton tai');
        }

        // Sap xep userA, userB
        let userA = from.toString();
        let userB = to;
        if (userA > userB) {
            [userA, userB] = [userB, userA];
        }

        // Kiem tra da la ban be hoac da gui loi moi
        const [alreadyFriends, pendingRequest] = await Promise.all([
            this.friendRepository.findByUsers(userA, userB),
            this.friendRequestRepository.findBetweenUsers(from, to as any)
        ]);

        if (alreadyFriends) {
            throw new Error('Hai nguoi da la ban be');
        }
        if (pendingRequest) {
            throw new Error('Da co loi moi ket ban dang cho duyet');
        }

        // Tao friend request
        const request = await this.friendRequestRepository.create(from, to as any, message);
        return request;
    }

    async acceptFriendRequest(requestId: string, userId: Types.ObjectId) {
        const request = await this.friendRequestRepository.findById(requestId);
        if (!request) {
            throw new Error('Khong tim thay loi moi ket ban');
        }

        if (request.to.toString() !== userId.toString()) {
            throw new Error('Khong co quyen chap nhan loi moi ket ban');
        }

        // Tao ban be
        await this.friendRepository.create(request.from, request.to);

        // Xoa friend request
        await this.friendRequestRepository.deleteById(requestId);

        // Lay thong tin nguoi gui
        const from = await this.userRepository.findByIdWithFields(
            request.from,
            'username displayName avatarUrl'
        );

        return {
            _id: from?._id,
            displayName: from?.displayName,
            avatarUrl: from?.avatarUrl
        };
    }

    async rejectFriendRequest(requestId: string, userId: Types.ObjectId) {
        const request = await this.friendRequestRepository.findById(requestId);
        if (!request) {
            throw new Error('Khong tim thay loi moi ket ban');
        }

        if (request.to.toString() !== userId.toString()) {
            throw new Error('Khong co quyen tu choi loi moi ket ban');
        }

        await this.friendRequestRepository.deleteById(requestId);
    }

    async getAllFriends(userId: Types.ObjectId) {
        const friendships = await this.friendRepository.findAllByUserId(userId);

        if (!friendships.length) {
            return [];
        }

        const friends = friendships.map((f: any) =>
            f.userA._id.toString() === userId.toString() ? f.userB : f.userA
        );

        return friends;
    }

    async getAllFriendRequests(userId: Types.ObjectId) {
        const populateFields = '_id username displayName avatarUrl';

        const [sent, received] = await Promise.all([
            this.friendRequestRepository.findSentByUserId(userId, populateFields),
            this.friendRequestRepository.findReceivedByUserId(userId, populateFields)
        ]);

        return { sent, received };
    }
}
