import type { PostRepository } from './posts.repo.js';

export interface PostRepositoryInterface extends Pick<
    PostRepository,
    | 'create'
    | 'findById'
    | 'findRawById'
    | 'findFeed'
    | 'countAll'
    | 'countByAuthorId'
    | 'findByAuthorId'
    | 'deleteById'
    | 'toggleLike'
    | 'addComment'
    | 'getComments'
    | 'save'
    | 'hidePost'
    | 'unhidePost'
> {}
