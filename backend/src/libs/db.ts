import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_CONNECTIONSTRING as string);
    console.log('Lien ket Database thanh cong');
  } catch (error) {
    console.error('Loi ket noi Database', error);
    throw error;
  }
};

export default connectDB;