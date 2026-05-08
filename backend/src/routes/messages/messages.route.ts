import express from "express";
import messageRoute from "./message/message.route.js";
import reactionRoute from "./reaction/reaction.route.js";
import readRoute from "./read/read.route.js";
import deleteRoute from "./delete/delete.route.js";

const router = express.Router();

router.use("/", messageRoute);
router.use("/", reactionRoute);
router.use("/", readRoute);
router.use("/", deleteRoute);

export default router;
