import { Request, Response, NextFunction } from "express";
import {
    PresenceService,
} from "../../../shared/socket/presence.service.js";
import type { PresenceServiceInterface } from "../../../shared/socket/presence.service.interface.js";
import { AppError } from "../../../shared/errors/app-error.js";

const presenceService: PresenceServiceInterface = PresenceService.getInstance();

const MAX_BATCH_SIZE = 100;

export const getOnlineStatuses = async (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    try {
        const { userIds } = req.body;

        if (!Array.isArray(userIds) || userIds.length === 0) {
            throw new AppError(
                "userIds la bat buoc va phai la mang khong rong",
                400,
            );
        }

        if (userIds.length > MAX_BATCH_SIZE) {
            throw new AppError(
                `Toi da ${MAX_BATCH_SIZE} userIds moi lan query`,
                400,
            );
        }

        // Validate mỗi phần tử là string
        const invalidIndex = userIds.findIndex(
            (id: unknown) => typeof id !== "string" || !id.trim(),
        );
        if (invalidIndex !== -1) {
            throw new AppError(
                `userIds[${invalidIndex}] khong hop le`,
                400,
            );
        }

        const statuses = await presenceService.getStatuses(userIds);

        return res.status(200).json({ data: statuses });
    } catch (error) {
        next(error);
    }
};
