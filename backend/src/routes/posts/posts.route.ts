import express from "express";
import feedRoute from "./feed/feed.route.js";
import postRoute from "./post/post.route.js";
import likeRoute from "./like/like.route.js";
import commentRoute from "./comment/comment.route.js";
import reportRoute from "./report/report.route.js";

const router = express.Router();

router.use("/", feedRoute);
router.use("/", postRoute);
router.use("/", likeRoute);
router.use("/", commentRoute);
router.use("/", reportRoute);

export default router;
