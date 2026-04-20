import express from "express";
import uploadRoute from "./upload/upload.route.js";

const router = express.Router();

router.use(uploadRoute);

export default router;
