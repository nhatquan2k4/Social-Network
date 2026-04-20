import express from "express";
import conversationRoute from "./conversation/conversation.route.js";
// import messageRoute from "./message/message.route";

const router = express.Router();

router.use("/", conversationRoute);
// router.use("/", messageRoute);

export default router;