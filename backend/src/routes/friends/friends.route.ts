import express from "express";
import requestRoute from "./request/request.route.js";
import friendRoute from "./friend/friend.route.js";

const router = express.Router();

router.use("/", requestRoute);
router.use("/", friendRoute);

export default router;