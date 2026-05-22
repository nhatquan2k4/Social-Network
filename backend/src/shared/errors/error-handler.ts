import { NextFunction, Request, Response } from 'express';
import { AppError } from './app-error.js';

export const errorHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): Response => {
  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      message: error.message,
      details: error.details ?? null,
    });
  }

  if (error instanceof Error) {
    console.error("❌ Internal Server Error:", error.stack || error.message);
    return res.status(500).json({ message: error.message });
  }

  console.error("❌ Unknown Server Error:", error);
  return res.status(500).json({ message: 'Unknown server error' });
};
