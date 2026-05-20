import { Types } from "mongoose";
import { FriendRepository } from "../../routes/friends/shared/friends.repo.js";
import { UserRepository } from "../../routes/users/shared/users.repo.js";
import { InMemoryPresenceStore, type PresenceStore } from "./presence.store.js";
import { emitUserPresence } from "./socket.emitter.js";
import type {
    PresenceEmitter,
    PresenceFriendRepository,
    PresenceServiceInterface,
    PresenceServiceOptions,
    PresenceUserRepository,
} from "./presence.service.interface.js";

export interface UserStatus {
    userId: string;
    isOnline: boolean;
    lastSeenAt: string | null;
}

/**
 * PresenceService — Singleton quản lý trạng thái online/offline.
 *
 * - Track connection count per user (hỗ trợ multi-tab).
 * - Offline delay 5s để tránh false offline khi refresh.
 * - Broadcast presence tới friends qua socket.
 * - Persist lastSeenAt khi user thực sự offline.
 */
export class PresenceService implements PresenceServiceInterface {
    private static instance: PresenceService;

    private store: PresenceStore;
    private offlineTimers = new Map<string, NodeJS.Timeout>();
    private friendRepo: PresenceFriendRepository;
    private userRepo: PresenceUserRepository;
    private offlineDelayMs: number;
    private emitPresence: PresenceEmitter;

    /** Delay trước khi đánh dấu offline (ms) — tránh false offline khi refresh tab */
    private static readonly DEFAULT_OFFLINE_DELAY_MS = 5_000;

    constructor(options: PresenceServiceOptions = {}) {
        this.store = options.store ?? new InMemoryPresenceStore();
        this.friendRepo = options.friendRepository ?? new FriendRepository();
        this.userRepo = options.userRepository ?? new UserRepository();
        this.offlineDelayMs =
            options.offlineDelayMs ?? PresenceService.DEFAULT_OFFLINE_DELAY_MS;
        this.emitPresence = options.emitPresence ?? emitUserPresence;
    }

    static getInstance(store?: PresenceStore): PresenceService {
        if (!PresenceService.instance) {
            PresenceService.instance = new PresenceService({ store });
        }
        return PresenceService.instance;
    }

    /**
     * Gọi khi socket connect.
     * Chỉ emit online khi chuyển từ 0→1 connection (tránh spam mỗi tab mới).
     */
    async handleConnect(userId: string): Promise<void> {
        // Cancel pending offline timer nếu user reconnect trong window 5s
        this.cancelOfflineTimer(userId);

        const count = await this.store.increment(userId);

        // Chỉ broadcast khi user vừa chuyển sang online (0 → 1)
        if (count === 1) {
            await this.broadcastPresence(userId, true);
        }
    }

    /**
     * Gọi khi socket disconnect.
     * Không mark offline ngay — delay 5s rồi double-check.
     */
    async handleDisconnect(userId: string): Promise<void> {
        const count = await this.store.decrement(userId);

        if (count === 0) {
            this.scheduleOffline(userId);
        }
    }

    /**
     * Query trạng thái online cho danh sách userIds.
     * Chỉ query DB (lastSeenAt) cho users offline — giảm load.
     */
    async getStatuses(userIds: string[]): Promise<UserStatus[]> {
        const onlineSet = await this.store.getOnlineUserIds(userIds);

        // Chỉ query DB cho users offline để lấy lastSeenAt
        const offlineIds = userIds.filter((id) => !onlineSet.has(id));
        const lastSeenMap =
            offlineIds.length > 0
                ? await this.userRepo.getLastSeenBatch(offlineIds)
                : new Map<string, Date | null>();

        return userIds.map((id) => ({
            userId: id,
            isOnline: onlineSet.has(id),
            lastSeenAt: onlineSet.has(id)
                ? null
                : lastSeenMap.get(id)?.toISOString() ?? null,
        }));
    }

    /**
     * Kiểm tra 1 user có online không (helper cho các service khác).
     */
    async isOnline(userId: string): Promise<boolean> {
        return this.store.isOnline(userId);
    }

    clearPendingOfflineTimers(): void {
        for (const timer of this.offlineTimers.values()) {
            clearTimeout(timer);
        }
        this.offlineTimers.clear();
    }

    // ── Private helpers ────────────────────────────────────

    private scheduleOffline(userId: string): void {
        const timer = setTimeout(async () => {
            this.offlineTimers.delete(userId);

            try {
                // Double-check: user có thể đã reconnect trong 5s delay
                const currentCount = await this.store.getCount(userId);
                if (currentCount > 0) return;

                // Persist lastSeenAt vào DB
                const now = new Date();
                await this.userRepo
                    .updateLastSeenAt(userId, now)
                    .catch((err: unknown) => {
                        console.error("Failed to persist lastSeenAt:", err);
                    });

                // Broadcast offline tới friends
                await this.broadcastPresence(userId, false);
            } catch (err) {
                console.error("Presence offline handler error:", err);
            }
        }, this.offlineDelayMs);

        this.offlineTimers.set(userId, timer);
    }

    private cancelOfflineTimer(userId: string): void {
        const existing = this.offlineTimers.get(userId);
        if (existing) {
            clearTimeout(existing);
            this.offlineTimers.delete(userId);
        }
    }

    private async broadcastPresence(userId: string, isOnline: boolean): Promise<void> {
        try {
            const friendIds = await this.friendRepo.getFriendIds(
                new Types.ObjectId(userId),
            );

            if (friendIds.length > 0) {
                this.emitPresence(userId, isOnline, friendIds);
            }
        } catch (err) {
            console.error("Presence broadcast error:", err);
        }
    }
}
