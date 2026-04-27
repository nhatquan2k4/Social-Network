import dotenv from 'dotenv';

dotenv.config();

export type NodeEnvironment = 'development' | 'production' | 'test';

type ValidationLevel = 'warning' | 'error';

type ValidationIssue = {
  level: ValidationLevel;
  key: string;
  message: string;
};

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

const parseNodeEnv = (value: string | undefined): NodeEnvironment => {
  if (value === 'production' || value === 'test') {
    return value;
  }

  return 'development';
};

const parseCorsOrigins = (value: string | undefined): string[] => {
  if (!value) {
    return [];
  }

  return value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
};

const nodeEnv = parseNodeEnv(process.env.NODE_ENV);

const minioPort = toNumber(process.env.MINIO_PORT, 9000);

export const envConfig = {
  port: toNumber(process.env.PORT, 3001),
  mongoConnectionString:
    process.env.MONGODB_CONNECTIONSTRING || 'mongodb://localhost:27018/social_network',
  corsOrigins: parseCorsOrigins(process.env.CORS_ORIGIN),
  nodeEnv,
  isProduction: nodeEnv === 'production',
  isDevelopment: nodeEnv === 'development',
  jwtSecret: process.env.ACCESS_TOKEN_SECRET || '',
  swaggerServerUrl:
    process.env.SWAGGER_SERVER_URL ||
    `http://localhost:${toNumber(process.env.PORT, 3001)}`,
  minioStrictStartup:
    toBoolean(process.env.MINIO_STRICT_STARTUP, false) || nodeEnv === 'production',
  minio: {
    endPoint: process.env.MINIO_ENDPOINT || 'localhost',
    port: minioPort,
    useSSL: toBoolean(process.env.MINIO_USE_SSL, false),
    accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
    secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
    publicBaseUrl: process.env.MINIO_PUBLIC_BASE_URL || 'http://localhost:9000',
    buckets: {
      post: process.env.MINIO_BUCKET_POSTS || 'social-posts',
      message: process.env.MINIO_BUCKET_MESSAGES || 'social-messages',
      avatar: process.env.MINIO_BUCKET_AVATARS || 'social-avatars',
    },
  },
  emailVerificationTokenTtlSeconds: toNumber(process.env.EMAIL_VERIFICATION_TOKEN_TTL_SECONDS, 900),
  emailVerificationResendCooldownSeconds: toNumber(process.env.EMAIL_VERIFICATION_RESEND_COOLDOWN_SECONDS, 60),
  emailVerificationRedirectUrl:
    process.env.EMAIL_VERIFICATION_REDIRECT_URL || 'http://localhost:3000/verify-email',
  mailFrom: process.env.MAIL_FROM || 'no-reply@socialnetwork.local',
  smtpHost: process.env.SMTP_HOST || '',
  smtpPort: toNumber(process.env.SMTP_PORT, 587),
  smtpUser: process.env.SMTP_USER || '',
  smtpPass: process.env.SMTP_PASS || '',
  smtpSecure: toBoolean(process.env.SMTP_SECURE, false),
};

export const validateEnvForStartup = (): void => {
  const issues: ValidationIssue[] = [];

  if (envConfig.jwtSecret.trim().length < 32) {
    issues.push({
      level: envConfig.isProduction ? 'error' : 'warning',
      key: 'ACCESS_TOKEN_SECRET',
      message: 'Nen co it nhat 32 ky tu de dam bao an toan cho JWT.',
    });
  }

  if (!/^mongodb(\+srv)?:\/\//.test(envConfig.mongoConnectionString)) {
    issues.push({
      level: envConfig.isProduction ? 'error' : 'warning',
      key: 'MONGODB_CONNECTIONSTRING',
      message: 'Gia tri phai bat dau bang mongodb:// hoac mongodb+srv://.',
    });
  }

  if (envConfig.isProduction && envConfig.corsOrigins.length === 0) {
    issues.push({
      level: 'error',
      key: 'CORS_ORIGIN',
      message: 'Production can cau hinh CORS_ORIGIN de gioi han domain hop le.',
    });
  }

  if (envConfig.isProduction && !envConfig.minio.endPoint.trim()) {
    issues.push({
      level: 'error',
      key: 'MINIO_ENDPOINT',
      message: 'Production can khai bao MINIO_ENDPOINT.',
    });
  }

  if (envConfig.isProduction && !envConfig.minio.accessKey.trim()) {
    issues.push({
      level: 'error',
      key: 'MINIO_ACCESS_KEY',
      message: 'Production can khai bao MINIO_ACCESS_KEY.',
    });
  }

  if (envConfig.isProduction && !envConfig.minio.secretKey.trim()) {
    issues.push({
      level: 'error',
      key: 'MINIO_SECRET_KEY',
      message: 'Production can khai bao MINIO_SECRET_KEY.',
    });
  }

  const warnings = issues.filter((issue) => issue.level === 'warning');
  const errors = issues.filter((issue) => issue.level === 'error');

  warnings.forEach((warning) => {
    console.warn(`[env:${warning.key}] ${warning.message}`);
  });

  if (errors.length > 0) {
    const message = errors
      .map((error) => `[env:${error.key}] ${error.message}`)
      .join(' | ');
    throw new Error(`Environment validation failed: ${message}`);
  }
};
