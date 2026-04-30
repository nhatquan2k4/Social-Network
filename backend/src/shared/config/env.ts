import dotenv from 'dotenv';

dotenv.config();

const toNumber = (value: string | undefined, fallback: number): number => {
  const parsed = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
};

const toBoolean = (value: string | undefined, fallback: boolean): boolean => {
  if (value === undefined) {
    return fallback;
  }

  const normalized = value.toLowerCase().trim();
  if (normalized === 'true' || normalized === '1' || normalized === 'yes') {
    return true;
  }

  if (normalized === 'false' || normalized === '0' || normalized === 'no') {
    return false;
  }

  return fallback;
};

export const envConfig = {
  port: toNumber(process.env.PORT, 3001),
  mongoConnectionString:
    process.env.MONGODB_CONNECTIONSTRING || 'mongodb://localhost:27017/social_network',
  corsOrigins: process.env.CORS_ORIGIN || '',
  nodeEnv: process.env.NODE_ENV || 'development',
  emailVerificationTokenTtlSeconds: toNumber(process.env.EMAIL_VERIFICATION_TOKEN_TTL_SECONDS, 900),
  emailVerificationResendCooldownSeconds: toNumber(process.env.EMAIL_VERIFICATION_RESEND_COOLDOWN_SECONDS, 60),
  emailVerificationRedirectUrl:
    process.env.EMAIL_VERIFICATION_REDIRECT_URL || 'http://localhost:3001/verify-email',
  mailFrom: process.env.MAIL_FROM || 'no-reply@socialnetwork.local',
  smtpHost: process.env.SMTP_HOST || '',
  smtpPort: toNumber(process.env.SMTP_PORT, 587),
  smtpUser: process.env.SMTP_USER || '',
  smtpPass: process.env.SMTP_PASS || '',
  smtpSecure: toBoolean(process.env.SMTP_SECURE, false),
};
