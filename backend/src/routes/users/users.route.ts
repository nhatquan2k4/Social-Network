import express from 'express';
import searchRoute from './search/search.route.js';
import statusRoute from './status/status.route.js';
import profileRoute from './profile/profile.route.js';
import userPostsRoute from './posts/user-posts.route.js';

const router = express.Router();

// Literal routes first to prevent /:userId param from capturing "search" or "status"
router.use(searchRoute);
router.use(statusRoute);
router.use(profileRoute);
router.use(userPostsRoute);

export default router;