import { Request, Response } from 'express';
import { NotificationService } from './notifications.service.js';

const notificationService = new NotificationService();

const toBoolean = (value: unknown) => {
  if (typeof value !== 'string') {
    return false;
  }

  return value.toLowerCase() === 'true' || value === '1';
};

export const getMyNotifications = async (req: Request, res: Response) => {
  try {
    const userId = req.user!._id;
    const page = Number(req.query.page || '1');
    const limit = Number(req.query.limit || '20');
    const unreadOnly = toBoolean(req.query.unreadOnly);

    const data = await notificationService.getMyNotifications(
      userId,
      page,
      limit,
      unreadOnly,
    );

    return res.status(200).json({ data });
  } catch (error) {
    console.error('Loi khi lay notifications', error);
    return res.status(500).json({ message: 'Loi server' });
  }
};

export const markNotificationAsRead = async (req: Request, res: Response) => {
  try {
    const userId = req.user!._id;
    const notificationId = Array.isArray(req.params.notificationId)
      ? req.params.notificationId[0]
      : req.params.notificationId;

    if (!notificationId) {
      return res.status(400).json({ message: 'Thieu notificationId' });
    }

    const data = await notificationService.markAsRead(notificationId, userId);

    return res.status(200).json({ message: 'Da danh dau da doc', data });
  } catch (error: any) {
    console.error('Loi khi danh dau notification da doc', error);

    if (error?.name === 'CastError') {
      return res.status(400).json({ message: 'notificationId khong hop le' });
    }

    if (error.message === 'Thong bao khong ton tai') {
      return res.status(404).json({ message: error.message });
    }

    return res.status(500).json({ message: 'Loi server' });
  }
};

export const markAllNotificationsAsRead = async (
  req: Request,
  res: Response,
) => {
  try {
    const userId = req.user!._id;
    const modifiedCount = await notificationService.markAllAsRead(userId);

    return res.status(200).json({
      message: 'Da danh dau tat ca notification da doc',
      modifiedCount,
    });
  } catch (error) {
    console.error('Loi khi danh dau tat ca notification da doc', error);
    return res.status(500).json({ message: 'Loi server' });
  }
};

export const saveFcmToken = async (req: Request, res: Response) => {
  try {
    const userId = req.user!._id;
    const { token, platform } = req.body;

    if (!token) {
      return res.status(400).json({
        message: 'Thieu FCM token',
      });
    }

    const data = await notificationService.saveFcmToken(
      userId,
      token,
      platform || 'android',
    );

    return res.status(200).json({
      message: 'Luu FCM token thanh cong',
      data,
    });
  } catch (error) {
    console.error('Loi khi luu FCM token', error);

    return res.status(500).json({
      message: 'Loi server khi luu FCM token',
    });
  }
};

export const testSendNotification = async (req: Request, res: Response) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({ message: 'Thiếu device token để gửi' });
    }

    const response = await notificationService.sendTestNotification(token);
    return res.status(200).json({ message: 'Đã gửi thành công!', response });
  } catch (error) {
    console.error('Lỗi khi gửi test notification:', error);
    return res.status(500).json({ message: 'Lỗi server khi gửi thông báo', error });
  }
};