import express from "express";
import uploadRoute from "./upload/upload.route";

const router = express.Router();

router.use(uploadRoute);

export default router;
