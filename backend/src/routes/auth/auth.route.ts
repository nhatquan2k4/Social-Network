import express from 'express';
import registerRoute from './register/register.route';
import loginRoute from './login/login.route';
import logoutRoute from './logout/logout.route';
import verifyEmailRoute from './email-verification/verify/verify.route';
import resendEmailRoute from './email-verification/resend/resend.route';

const router = express.Router();

router.use(registerRoute);
router.use(loginRoute);
router.use(logoutRoute);
router.use(verifyEmailRoute);
router.use(resendEmailRoute);

export default router;