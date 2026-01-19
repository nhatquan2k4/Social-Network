import { Request, Response } from 'express';
import { FriendService } from '../services/friendService';

const friendService = new FriendService();

export const sendFriendRequest = async (req: Request, res: Response) => {
    try {
        const { to, message } = req.body;
        const from = req.user!._id;
        const request = await friendService.sendFriendRequest(from, to, message);
        return res.status(200).json({ message: 'Da gui loi moi ket ban', request });
    } catch (error: any) {
        console.error('Loi khi gui loi moi ket ban', error);
        if (error.message === 'Khong the gui loi moi ket ban voi chinh ban than') {
            return res.status(400).json({ message: error.message });
        }
        if (error.message === 'Nguoi dung khong ton tai') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Hai nguoi da la ban be' || error.message === 'Da co loi moi ket ban dang cho duyet') {
            return res.status(400).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const acceptFriendRequest = async (req: Request, res: Response) => {
    try {
        const { requestId } = req.body;
        const userId = req.user!._id;

        const newFriend = await friendService.acceptFriendRequest(requestId, userId);

        return res.status(200).json({
            message: 'Da chap nhan loi moi ket ban',
            newFriend
        });
    } catch (error: any) {
        console.error('Loi khi chap nhan loi moi ket ban', error);
        if (error.message === 'Khong tim thay loi moi ket ban') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Khong co quyen chap nhan loi moi ket ban') {
            return res.status(403).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const rejectFriendRequest = async (req: Request, res: Response) => {
    try {
        const { requestId } = req.params;
        const userId = req.user!._id;

        await friendService.rejectFriendRequest(requestId as string, userId);

        return res.status(204).json({ message: 'Da tu choi loi moi ket ban' });
    } catch (error: any) {
        console.error('Loi khi tu choi loi moi ket ban', error);
        if (error.message === 'Khong tim thay loi moi ket ban') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Khong co quyen tu choi loi moi ket ban') {
            return res.status(403).json({ message: error.message });
        }
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const getAllFriend = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;

        const friends = await friendService.getAllFriends(userId);

        return res.status(200).json({ friends });
    } catch (error) {
        console.error('Loi khi lay danh sach ban be', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};

export const getAllFriendRequest = async (req: Request, res: Response) => {
    try {
        const userId = req.user!._id;

        const { sent, received } = await friendService.getAllFriendRequests(userId);

        return res.status(200).json({ sent, received });
    } catch (error) {
        console.error('Loi khi lay danh sach loi moi ket ban', error);
        return res.status(500).json({ message: 'Loi server' });
    }
};