import type { FriendRepositoryInterface } from '../../routes/friends/shared/friends.repo.interface.js';
import type { UserRepositoryInterface } from '../../routes/users/shared/users.repo.interface.js';
import type { PresenceStore } from './presence.store.js';
import type { PresenceService } from './presence.service.js';

export type PresenceFriendRepository = Pick<FriendRepositoryInterface, 'getFriendIds'>;
export type PresenceUserRepository = Pick<
    UserRepositoryInterface,
    'getLastSeenBatch' | 'updateLastSeenAt'
>;
export type PresenceEmitter = (
    userId: string,
    isOnline: boolean,
    friendIds: string[],
) => void;

export interface PresenceServiceOptions {
    store?: PresenceStore;
    friendRepository?: PresenceFriendRepository;
    userRepository?: PresenceUserRepository;
    offlineDelayMs?: number;
    emitPresence?: PresenceEmitter;
}

export interface PresenceServiceInterface {
    handleConnect: PresenceService['handleConnect'];
    handleDisconnect: PresenceService['handleDisconnect'];
    getStatuses: PresenceService['getStatuses'];
    isOnline: PresenceService['isOnline'];
    clearPendingOfflineTimers: PresenceService['clearPendingOfflineTimers'];
}
