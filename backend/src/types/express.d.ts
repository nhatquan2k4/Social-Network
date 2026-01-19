import { Document } from 'mongoose';
import type Conversation from '../models/conversation';

interface UserDocument extends Document {
  username: string;
  hashedPassword: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  avatarPublicId?: string;
  bio?: string;
  phone?: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: UserDocument;
      conversation?: InstanceType<typeof Conversation>;
    }
  }
}
