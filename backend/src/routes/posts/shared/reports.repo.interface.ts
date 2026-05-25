import type { ReportRepository } from './reports.repo.js';

export interface ReportRepositoryInterface extends Pick<
    ReportRepository,
    | 'create'
    | 'findByPostAndReporter'
    | 'countByPostId'
    | 'findByPostId'
    | 'findPending'
    | 'updateStatus'
> {}
