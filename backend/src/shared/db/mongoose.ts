import mongoose from "mongoose";
import { envConfig } from "../config/env.js";

const connectDB = async (connectionString = envConfig.mongoConnectionString) => {
    try {
        await mongoose.connect(connectionString);
        console.log("Lien ket Database thanh cong");
    } catch (error) {
        console.error("Loi ket noi Database", error);
        throw error;
    }
};

const disconnectDB = async () => {
    await mongoose.disconnect();
};

export { connectDB, disconnectDB };
export default connectDB;
