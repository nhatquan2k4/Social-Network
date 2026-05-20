import type { PostRepositoryInterface } from '../shared/posts.repo.interface.js';
import type { ReportRepositoryInterface } from '../shared/reports.repo.interface.js';
import type { ReportService } from './report.service.js';

export type ReportPostRepository = Pick<PostRepositoryInterface, 'findRawById' | 'hidePost'>;
export type ReportPostReportRepository = Pick<
    ReportRepositoryInterface,
    'findByPostAndReporter' | 'create' | 'countByPostId'
>;

export interface ReportServiceDependencies {
    postRepository?: ReportPostRepository;
    reportRepository?: ReportPostReportRepository;
}

export interface ReportServiceInterface {
    reportPost: ReportService['reportPost'];
}
