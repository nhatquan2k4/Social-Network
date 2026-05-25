import type { PostRepositoryInterface } from '../shared/posts.repo.interface.js';
import type { PostService } from './post.service.js';

export type PostServicePostRepository = Pick<
    PostRepositoryInterface,
    'create' | 'findById' | 'findRawById' | 'save' | 'deleteById'
>;

export interface PostServiceDependencies {
    postRepository?: PostServicePostRepository;
}

export interface PostServiceInterface {
    createPost: PostService['createPost'];
    getPostById: PostService['getPostById'];
    updatePost: PostService['updatePost'];
    deletePost: PostService['deletePost'];
}
