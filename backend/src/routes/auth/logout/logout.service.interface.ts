import type { SessionRepositoryInterface } from '../shared/auth.repo.interface.js';
import type { LogoutService } from './logout.service.js';

export type LogoutSessionRepository = Pick<
    SessionRepositoryInterface,
    'deleteByRefreshToken'
>;

export interface LogoutServiceDependencies {
    sessionRepository?: LogoutSessionRepository;
}

export interface LogoutServiceInterface {
    execute: LogoutService['execute'];
}
