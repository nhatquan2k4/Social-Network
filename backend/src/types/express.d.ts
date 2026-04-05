import { Document } from 'mongoose';
import type { ConversationModel } from '../routes/conversations/conversations.model';

interface UserDocument extends Document {
  username: string;
  hashedPassword: string;
  email: string;
  isEmailVerified?: boolean;
  emailVerifiedAt?: Date | null;
  emailVerificationSentAt?: Date | null;
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
      conversation?: InstanceType<typeof ConversationModel>;
    }
  }
}
