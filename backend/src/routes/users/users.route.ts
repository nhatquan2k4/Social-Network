import express from 'express';
import profileRoute from './profile/profile.route';
import userPostsRoute from './posts/user-posts.route';

const router = express.Router();

router.use(profileRoute);
router.use(userPostsRoute);

export default router;