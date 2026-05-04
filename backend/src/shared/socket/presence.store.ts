/**
 * PresenceStore interface — Strategy Pattern
 * Phase 1: InMemoryPresenceStore (single instance)
 * Phase 2: Swap to RedisPresenceStore (multi instance) without changing business logic.
 */

export interface PresenceStore {
    /** Tăng connection count cho user, trả về count mới */
    increment(userId: string): Promise<number>;
    /** Giảm connection count cho user, trả về count mới (min 0) */
    decrement(userId: string): Promise<number>;
    /** Lấy connection count hiện tại */
    getCount(userId: string): Promise<number>;
    /** Kiểm tra user có online không */
    isOnline(userId: string): Promise<boolean>;
    /** Batch check — trả về Set chứa userId đang online */
    getOnlineUserIds(userIds: string[]): Promise<Set<string>>;
}

export class InMemoryPresenceStore implements PresenceStore {
    private connections = new Map<string, number>();

    async increment(userId: string): Promise<number> {
        const current = this.connections.get(userId) ?? 0;
        const next = current + 1;
        this.connections.set(userId, next);
        return next;
    }

    async decrement(userId: string): Promise<number> {
        const current = this.connections.get(userId) ?? 0;
        const next = Math.max(0, current - 1);
        if (next === 0) {
            this.connections.delete(userId);
        } else {
            this.connections.set(userId, next);
        }
        return next;
    }

    async getCount(userId: string): Promise<number> {
        return this.connections.get(userId) ?? 0;
    }

    async isOnline(userId: string): Promise<boolean> {
        return (this.connections.get(userId) ?? 0) > 0;
    }

    async getOnlineUserIds(userIds: string[]): Promise<Set<string>> {
        const onlineSet = new Set<string>();
        for (const id of userIds) {
            if ((this.connections.get(id) ?? 0) > 0) {
                onlineSet.add(id);
            }
        }
        return onlineSet;
    }
}
