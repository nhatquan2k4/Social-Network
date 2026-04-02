import dotenv from 'dotenv';

dotenv.config();

const toNumber = (value: string | undefined, fallback: number): number => {
  const parsed = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
};

export const envConfig = {
  port: toNumber(process.env.PORT, 3001),
  mongoConnectionString:
    process.env.MONGODB_CONNECTIONSTRING || 'mongodb://localhost:27018/social_network',
  corsOrigins: process.env.CORS_ORIGIN || '',
  nodeEnv: process.env.NODE_ENV || 'development',
};
