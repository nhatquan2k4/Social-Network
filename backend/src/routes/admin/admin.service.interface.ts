import type { PostRepositoryInterface } from '../posts/shared/posts.repo.interface.js';
import type { ReportRepositoryInterface } from '../posts/shared/reports.repo.interface.js';
import type { AdminService } from './admin.service.js';

export type AdminPostRepository = Pick<
    PostRepositoryInterface,
    'findRawById' | 'hidePost' | 'unhidePost' | 'deleteById'
>;
export type AdminReportRepository = Pick<
    ReportRepositoryInterface,
    'findPending' | 'findByPostId' | 'countByPostId' | 'updateStatus'
>;

export interface AdminServiceDependencies {
    postRepository?: AdminPostRepository;
    reportRepository?: AdminReportRepository;
}

export interface AdminServiceInterface {
    getPendingReports: AdminService['getPendingReports'];
    getReportsByPost: AdminService['getReportsByPost'];
    hidePost: AdminService['hidePost'];
    restorePost: AdminService['restorePost'];
    deletePost: AdminService['deletePost'];
    reviewReport: AdminService['reviewReport'];
}
