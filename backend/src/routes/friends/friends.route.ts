import express from "express";
import requestRoute from "./request/request.route";
import friendRoute from "./friend/friend.route";

const router = express.Router();

router.use("/", requestRoute);
router.use("/", friendRoute);

export default router;