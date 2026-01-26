import { PostRepository, CreatePostData, UpdatePostData, FindPostsOptions, CountPostFilter } from "../../repositories/Post/postRepository";
import { Types } from "mongoose";

export class PostService {
    private postRepository: PostRepository;

    constructor() {
        this.postRepository = new PostRepository();
    }

    /**
     * Tìm post theo ID
     */

    async getPostById(postId: string | Types.ObjectId, populate: boolean = false) {
        const post = await this.postRepository.findById(postId, populate);
        if (!post) {
            throw new Error("Post khong ton tai");
        }
        return post;
    }

    async getPostsByIds(postIds: (string | Types.ObjectId)[], populate: boolean = false) {
        const posts = await this.postRepository.findByIds(postIds, populate);
        if (posts.length === 0) {
            throw new Error("Khong co post nao ton tai");
        }
        return posts;
    }

    /**
     * Tạo post mới
     */

    async createPost(createPostData: CreatePostData) {
        const newPost = await this.postRepository.create(createPostData);
        return newPost;
    }

    /**
    * Cập nhật post
    */

    async updatePost(postId: string | Types.ObjectId, updatePostData: UpdatePostData) {
        const updatedPost = await this.postRepository.update(postId, updatePostData);
        if (!updatedPost) {
            throw new Error("Post khong ton tai");
        }
        return updatedPost;
    }

    /**
    * Xóa post
    */
    async deletePost(postId: string | Types.ObjectId) {
        const deleted = await this.postRepository.delete(postId);
        if (!deleted) {
            throw new Error("Post khong ton tai");
        }
        return deleted;
    }

    /**
     * Xóa nhiều post theo userId
     */
    async deletePostByUserId(userId: string | Types.ObjectId) {
        return await this.postRepository.deleteByUserId(userId);
    }   
    
    /**
     * Tìm posts theo userId với các filter options
     */
    async findPostsByUserId(userId: string | Types.ObjectId, options?: Omit<FindPostsOptions, "userId">) {
        return await this.postRepository.findByUserId(userId, options);
    }

    /**
     * Tìm posts với các filter options
     */
    async findAll(options?: FindPostsOptions) {
        return await this.postRepository.findAll(options);
    }

    /**
     * Đếm số lượng posts với các filter options
     */
    async countPosts(filter?: Partial<CountPostFilter>) {
        return await this.postRepository.count(filter);
    }




}