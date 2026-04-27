import { NextFunction, Request, Response } from 'express';
import { AppError } from './app-error';
import { envConfig } from '../config/env';

export const errorHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): Response => {
  if (error instanceof AppError) {
    const safeMessage = envConfig.isProduction && error.statusCode >= 500
      ? 'Internal server error'
      : error.message;

    return res.status(error.statusCode).json({
      message: safeMessage,
      details: error.details ?? null,
    });
  }

  if (error instanceof Error) {
    console.error('Unhandled error:', error);
    return res.status(500).json({
      message: envConfig.isProduction ? 'Internal server error' : error.message,
    });
  }

  console.error('Unknown error payload:', error);
  return res.status(500).json({ message: 'Unknown server error' });
};
