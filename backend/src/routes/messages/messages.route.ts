import express from "express";
import messageRoute from "./message/message.route";
import reactionRoute from "./reaction/reaction.route";
import readRoute from "./read/read.route";

const router = express.Router();

router.use("/", messageRoute);
router.use("/", reactionRoute);
router.use("/", readRoute);

export default router;