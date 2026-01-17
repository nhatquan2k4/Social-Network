import express from 'express';
import dotenv from 'dotenv';
import connectDB from './libs/db';
import authRoutes from './routes/authRoutes';
import cookieParser from 'cookie-parser';
import userRoutes from './routes/userRoutes';
import { protectedRoute } from './middlewares/authMiddleware';

dotenv.config();

const app = express();

const PORT = process.env.PORT || 5001;

// middleware
app.use(express.json());
app.use(cookieParser());

// public routes
app.use('/api/auth', authRoutes);

// private routes
app.use(protectedRoute);
app.use('/api/users', userRoutes);

app.get('/', (req, res) => {
  res.send('Hello World!');
});

connectDB().then(() => {
  console.log('Connected to the database successfully');
}).catch((error) => {
  console.error('Database connection failed:', error);
});

app.listen(PORT, () => {
  console.log(`Server is running on port localhost:${PORT}`);
});