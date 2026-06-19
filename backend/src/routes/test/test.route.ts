import express from 'express';

const router = express.Router();

router.get('/health', (_req, res) => {
    res.status(200).json({
        ok: true,
        mode: 'e2e-test',
    });
});

export default router;
