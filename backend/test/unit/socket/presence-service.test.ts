import assert from "node:assert/strict";
import { afterEach, describe, it } from "node:test";
import { Types } from "mongoose";
import { InMemoryPresenceStore } from "../../../src/shared/socket/presence.store.js";
import { PresenceService } from "../../../src/shared/socket/presence.service.js";

const wait = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

const userId = "507f1f77bcf86cd799439011";
const friendId = "507f1f77bcf86cd799439012";

interface PresenceEvent {
    userId: string;
    isOnline: boolean;
    friendIds: string[];
}

class FakeFriendRepository {
    async getFriendIds(requestedUserId: Types.ObjectId) {
        assert.equal(requestedUserId.toString(), userId);
        return [friendId];
    }
}

class FakeUserRepository {
    lastSeenUpdates: Array<{ userId: string; lastSeenAt: Date }> = [];

    async getLastSeenBatch(userIds: string[]) {
        return new Map(userIds.map((id) => [id, null]));
    }

    async updateLastSeenAt(updatedUserId: string, lastSeenAt: Date) {
        this.lastSeenUpdates.push({ userId: updatedUserId, lastSeenAt });
    }
}

const services: PresenceService[] = [];

const createPresenceService = (offlineDelayMs = 5) => {
    const userRepository = new FakeUserRepository();
    const events: PresenceEvent[] = [];
    const service = new PresenceService({
        store: new InMemoryPresenceStore(),
        friendRepository: new FakeFriendRepository(),
        userRepository,
        offlineDelayMs,
        emitPresence: (eventUserId, isOnline, friendIds) => {
            events.push({ userId: eventUserId, isOnline, friendIds });
        },
    });

    services.push(service);
    return { service, userRepository, events };
};

afterEach(() => {
    for (const service of services.splice(0)) {
        service.clearPendingOfflineTimers();
    }
});

describe("presence service", () => {
    it("emits online once and delays offline until the last connection closes", async () => {
        const { service, userRepository, events } = createPresenceService();

        await service.handleConnect(userId);
        await service.handleConnect(userId);

        assert.deepEqual(events, [
            {
                userId,
                isOnline: true,
                friendIds: [friendId],
            },
        ]);

        await service.handleDisconnect(userId);
        await wait(15);

        assert.equal(userRepository.lastSeenUpdates.length, 0);
        assert.equal(events.length, 1);

        await service.handleDisconnect(userId);
        await wait(15);

        assert.equal(userRepository.lastSeenUpdates.length, 1);
        assert.equal(userRepository.lastSeenUpdates[0].userId, userId);
        assert.deepEqual(events[1], {
            userId,
            isOnline: false,
            friendIds: [friendId],
        });
    });

    it("cancels pending offline when the user reconnects before the delay", async () => {
        const { service, userRepository, events } = createPresenceService(20);

        await service.handleConnect(userId);
        await service.handleDisconnect(userId);
        await service.handleConnect(userId);
        await wait(30);

        assert.equal(userRepository.lastSeenUpdates.length, 0);
        assert.equal(events.some((event) => event.isOnline === false), false);
    });
});
