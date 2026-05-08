import express from 'express';
import registerRoute from './register/register.route.js';
import loginRoute from './login/login.route.js';
import logoutRoute from './logout/logout.route.js';
import verifyEmailRoute from './email-verification/verify/verify.route.js';
import resendEmailRoute from './email-verification/resend/resend.route.js';
import refreshTokenRoute from './refresh-token/refresh-token.route.js';
import changePasswordRoute from './change-password/change-password.route.js';
import forgotPasswordRoute from './forgot-password/forgot-password.route.js';

const router = express.Router();

router.use(registerRoute);
router.use(loginRoute);
router.use(logoutRoute);
router.use(verifyEmailRoute);
router.use(resendEmailRoute);
router.use(refreshTokenRoute);
router.use(changePasswordRoute);
router.use(forgotPasswordRoute);

export default router;