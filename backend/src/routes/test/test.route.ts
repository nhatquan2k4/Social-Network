import express from 'express';
import {
    assertE2ETestApiEnabled,
    resetE2EDatabase,
    seedE2EDatabase,
} from '../../testing/e2e-seed.js';

const router = express.Router();

router.use((_req, res, next) => {
    try {
        assertE2ETestApiEnabled();
        next();
    } catch {
        res.status(404).json({ message: 'Not found' });
    }
});

router.get('/health', (_req, res) => {
    res.status(200).json({
        ok: true,
        mode: 'e2e-test',
    });
});

router.post('/reset', async (_req, res, next) => {
    try {
        await resetE2EDatabase();
        res.status(200).json({ ok: true, message: 'Database reset successfully' });
    } catch (error) {
        next(error);
    }
});

router.post('/seed', async (req, res, next) => {
    try {
        const seed = await seedE2EDatabase({
            runId: req.body?.runId,
            scenario: req.body?.scenario,
            reset: req.body?.reset !== false,
        });

        res.status(200).json({
            ok: true,
            seed,
        });
    } catch (error) {
        next(error);
    }
});

export default router;
