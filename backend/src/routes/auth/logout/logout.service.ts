import { SessionRepository } from '../shared/auth.repo.js';

export class LogoutService {
    private sessionRepository: SessionRepository;

    constructor() {
        this.sessionRepository = new SessionRepository();
    }

    async execute(refreshToken: string) {
        await this.sessionRepository.deleteByRefreshToken(refreshToken);
    }
}
