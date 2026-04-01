import { Types } from 'mongoose';

export const isValidObjectId = (value: string): boolean => {
  return Types.ObjectId.isValid(value);
};
