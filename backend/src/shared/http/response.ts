import { Response } from 'express';

export const sendSuccess = <T>(res: Response, data: T, status = 200) => {
  return res.status(status).json({ data });
};

export const sendCreated = <T>(res: Response, data: T, message = 'Created') => {
  return res.status(201).json({ message, data });
};

export const sendError = (res: Response, message: string, status = 400) => {
  return res.status(status).json({ message });
};
