import express from 'express';
import profileRoute from './profile/profile.route.js';
import userPostsRoute from './posts/user-posts.route.js';

const router = express.Router();

router.use(profileRoute);
router.use(userPostsRoute);

export default router;