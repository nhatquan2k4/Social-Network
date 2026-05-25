import nodemailer, { Transporter } from "nodemailer";
import { envConfig } from "../config/env.js";

let transporterInstance: Transporter | null = null;

const getTransporter = (): Transporter | null => {
    if (process.env.IS_E2E === "true") {
        return null;
    }

    if (transporterInstance) {
        return transporterInstance;
    }

    if (!envConfig.smtpHost || !envConfig.smtpUser || !envConfig.smtpPass) {
        return null;
    }

    transporterInstance = nodemailer.createTransport({
        host: envConfig.smtpHost,
        port: envConfig.smtpPort,
        secure: envConfig.smtpSecure,
        auth: {
            user: envConfig.smtpUser,
            pass: envConfig.smtpPass,
        },
    });

    return transporterInstance;
};

const appendTokenToUrl = (baseUrl: string, token: string): string => {
    const separator = baseUrl.includes("?") ? "&" : "?";
    return `${baseUrl}${separator}token=${encodeURIComponent(token)}`;
};

export const sendEmailVerificationEmail = async (
    recipientEmail: string,
    displayName: string,
    verificationToken: string,
) => {
    const verifyLink = appendTokenToUrl(envConfig.emailVerificationRedirectUrl, verificationToken);
    const transporter = getTransporter();

    if (!transporter) {
        console.warn("SMTP is not configured. Verification email was not sent.");
        console.info(`Verification link for ${recipientEmail}: ${verifyLink}`);
        return { sent: false, verifyLink };
    }

    const subject = "Xac thuc email tai khoan Social Network";
    const text = [
        `Chao ${displayName},`,
        "",
        "Cam on ban da dang ky tai khoan.",
        "Vui long xac thuc email bang cach mo lien ket ben duoi:",
        verifyLink,
        "",
        "Neu ban khong tao tai khoan, vui long bo qua email nay.",
    ].join("\n");

    await transporter.sendMail({
        from: envConfig.mailFrom,
        to: recipientEmail,
        subject,
        text,
    });

    return { sent: true, verifyLink };
};

export const sendForgotPasswordEmail = async (
    recipientEmail: string,
    displayName: string,
    newPassword: string,
) => {
    const transporter = getTransporter();

    if (!transporter) {
        console.warn('SMTP is not configured. Forgot password email was not sent.');
        console.info(`New password for ${recipientEmail}: ${newPassword}`);
        return { sent: false };
    }

    const subject = 'Mat khau moi tai khoan Social Network';
    const text = [
        `Chao ${displayName},`,
        '',
        'Chung toi nhan duoc yeu cau dat lai mat khau cua ban.',
        'Mat khau moi cua ban la:',
        '',
        `    ${newPassword}`,
        '',
        'Vui long dang nhap va doi mat khau ngay sau khi nhan duoc email nay.',
        'Neu ban khong yeu cau dat lai mat khau, vui long bo qua email nay.',
    ].join('\n');

    await transporter.sendMail({
        from: envConfig.mailFrom,
        to: recipientEmail,
        subject,
        text,
    });

    return { sent: true };
};
