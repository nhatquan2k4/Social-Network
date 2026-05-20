import { Request, Response } from "express";
import { FRIEND_SUCCESS_MESSAGES } from "../shared/friends.constants.js";
import {
    AlreadyFriendsError,
    FriendRequestAcceptForbiddenError,
    FriendRequestNotFoundError,
    FriendRequestPendingError,
    FriendRequestRejectForbiddenError,
    FriendSelfRequestError,
    FriendUserNotFoundError,
    MissingFriendRequestIdError,
    MissingFriendRecipientError,
} from "../shared/friends.errors.js";
import { RequestService } from "./request.service.js";
import type { RequestServiceInterface } from "./request.service.interface.js";

const requestService: RequestServiceInterface = new RequestService();

export const sendFriendRequest = async (req: Request, res: Response) => {
    try {
        const { to, message } = req.body;

        if (!to) {
            throw new MissingFriendRecipientError();
        }

        const from = req.user!._id;
        const request = await requestService.sendFriendRequest(from, to, message);

        return res.status(200).json({
            message: FRIEND_SUCCESS_MESSAGES.REQUEST_SENT,
            request,
        });
    } catch (error: any) {
        console.error("Loi khi gui loi moi ket ban", error);

        if (
            error instanceof MissingFriendRecipientError ||
            error instanceof FriendSelfRequestError ||
            error instanceof AlreadyFriendsError ||
            error instanceof FriendRequestPendingError
        ) {
            return res.status(400).json({ message: error.message });
        }

        if (error instanceof FriendUserNotFoundError) {
            return res.status(404).json({ message: error.message });
        }

        return res.status(500).json({ message: "Loi server" });
    }
};

export const acceptFriendRequest = async (req: Request, res: Response) => {
    try {
        const requestId = req.params.requestId || req.body?.requestId;

        if (!requestId) {
            throw new MissingFriendRequestIdError();
        }

        const userId = req.user!._id;
        const newFriend = await requestService.acceptFriendRequest(requestId, userId);

        return res.status(200).json({
            message: FRIEND_SUCCESS_MESSAGES.REQUEST_ACCEPTED,
            newFriend,
        });
    } catch (error: any) {
        console.error("Loi khi chap nhan loi moi ket ban", error);

        if (error?.name === "CastError") {
            return res.status(400).json({ message: "requestId khong hop le" });
        }

        if (error instanceof MissingFriendRequestIdError) {
            return res.status(400).json({ message: error.message });
        }

        if (error instanceof FriendRequestNotFoundError) {
            return res.status(404).json({ message: error.message });
        }

        if (error instanceof FriendRequestAcceptForbiddenError) {
            return res.status(403).json({ message: error.message });
        }

        return res.status(500).json({ message: "Loi server" });
    }
};

export const rejectFriendRequest = async (req: Request, res: Response) => {
    try {
        const { requestId } = req.params;
        const userId = req.user!._id;

        if (!requestId) {
            throw new MissingFriendRequestIdError();
        }

        await requestService.rejectFriendRequest(requestId as string, userId);

        return res.status(204).json({ message: FRIEND_SUCCESS_MESSAGES.REQUEST_REJECTED });
    } catch (error: any) {
        console.error("Loi khi tu choi loi moi ket ban", error);

        if (error instanceof MissingFriendRequestIdError) {
            return res.status(400).json({ message: error.message });
        }

        if (error instanceof FriendRequestNotFoundError) {
            return res.status(404).json({ message: error.message });
        }

        if (error instanceof FriendRequestRejectForbiddenError) {
            return res.status(403).json({ message: error.message });
        }

        return res.status(500).json({ message: "Loi server" });
    }
};

export const getAllFriendRequest = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;
        const { sent, received } = await requestService.getAllFriendRequests(userId);

        return res.status(200).json({ sent, received });
    } catch (error) {
        console.error("Loi khi lay danh sach loi moi ket ban", error);
        return res.status(500).json({ message: "Loi server" });
    }
};
