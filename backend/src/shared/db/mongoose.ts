import mongoose from 'mongoose';
import { envConfig } from '../config/env';

const connectDB = async () => {
	try {
		await mongoose.connect(envConfig.mongoConnectionString, {
			maxPoolSize: envConfig.isProduction ? 50 : 10,
			serverSelectionTimeoutMS: envConfig.isProduction ? 10000 : 5000,
			socketTimeoutMS: envConfig.isProduction ? 45000 : 20000,
		});
		console.log('Lien ket Database thanh cong');
	} catch (error) {
		console.error('Loi ket noi Database', error);
		throw error;
	}
};

export { connectDB };
export default connectDB;
