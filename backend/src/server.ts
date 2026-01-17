import express from 'express';
import dotenv from 'dotenv';
import connectDB from './libs/db';


dotenv.config();

const app = express();

const PORT = process.env.PORT || 5001;

app.use(express.json());

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