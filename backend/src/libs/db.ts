import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    const connectionString =
      process.env.MONGODB_CONNECTIONSTRING ||
      'mongodb://localhost:27018/social_network';

    await mongoose.connect(connectionString);
    console.log('Lien ket Database thanh cong');
  } catch (error) {
    console.error('Loi ket noi Database', error);
    throw error;
  }
};

export default connectDB;