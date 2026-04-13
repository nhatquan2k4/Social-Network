import express from "express";
import feedRoute from "./feed/feed.route";
import postRoute from "./post/post.route";
import likeRoute from "./like/like.route";
import commentRoute from "./comment/comment.route";

const router = express.Router();

router.use("/", feedRoute);
router.use("/", postRoute);
router.use("/", likeRoute);
router.use("/", commentRoute);

export default router;
