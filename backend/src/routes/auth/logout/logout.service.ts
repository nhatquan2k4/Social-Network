import { SessionRepository } from '../shared/auth.repo.js';
import type {
    LogoutServiceDependencies,
    LogoutServiceInterface,
    LogoutSessionRepository,
} from './logout.service.interface.js';

export class LogoutService implements LogoutServiceInterface {
    private sessionRepository: LogoutSessionRepository;

    constructor(dependencies: LogoutServiceDependencies = {}) {
        this.sessionRepository =
            dependencies.sessionRepository ?? new SessionRepository();
    }

    async execute(refreshToken: string) {
        await this.sessionRepository.deleteByRefreshToken(refreshToken);
    }
}
