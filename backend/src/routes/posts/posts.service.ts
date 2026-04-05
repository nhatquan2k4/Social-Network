import { Types } from "mongoose";
import { FriendModel as Friend } from "../friends/friends.model";
import { buildMediaUrl } from "../../shared/config/minio";
import { PostMediaInput, PostRepository } from "./posts.repo";
import { NotificationService } from "../notifications/notifications.service";

interface PostDocumentLike {
  _id: Types.ObjectId;
  authorId: any;
  content?: string;
  media?: Array<{ bucket: string; objectKey: string; mimeType: string; size: number }>;
  likes?: Types.ObjectId[];
  comments?: Array<{
    _id: Types.ObjectId;
    authorId: any;
    content: string;
    createdAt: Date;
    updatedAt: Date;
  }>;
  commentsCount?: number;
  createdAt: Date;
  updatedAt: Date;
}

interface PostCommentLike {
  _id: Types.ObjectId;
  parentCommentId?: Types.ObjectId | null;
  authorId: any;
  content: string;
  createdAt: Date;
  updatedAt: Date;
}

interface UpdatePostPayload {
  content?: string;
  hasContentField: boolean;
  mediaFromBody?: PostMediaInput[];
  hasMediaField: boolean;
  uploadedMedia?: PostMediaInput[];
}

export class PostService {
  private postRepository: PostRepository;
  private notificationService: NotificationService;

  constructor() {
    this.postRepository = new PostRepository();
    this.notificationService = new NotificationService();
  }

  private formatPost(post: PostDocumentLike) {
    const normalizedPost: any =
      post && typeof (post as any).toObject === "function"
        ? (post as any).toObject()
        : post;

    const media = (normalizedPost.media || []).map((item: any) => ({
      ...item,
      mediaUrl: buildMediaUrl(item.bucket, item.objectKey),
    }));

    const normalizedId =
      normalizedPost?._id != null
        ? normalizedPost._id.toString()
        : normalizedPost?.id != null
        ? normalizedPost.id.toString()
        : undefined;

    return {
      ...normalizedPost,
      ...(normalizedId ? { _id: normalizedId } : {}),
      media,
      likesCount: normalizedPost.likes?.length || 0,
    };
  }

  private formatComment(comment: PostCommentLike) {
    return {
      _id: comment._id,
      parentCommentId: comment.parentCommentId || null,
      authorId: comment.authorId,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
    };
  }

  private buildCommentTree(comments: any[]) {
    const map = new Map<string, any>();
    const roots: any[] = [];

    comments.forEach((comment) => {
      map.set(comment._id.toString(), {
        ...comment,
        children: [],
      });
    });

    comments.forEach((comment) => {
      const node = map.get(comment._id.toString());
      const parentId = comment.parentCommentId ? comment.parentCommentId.toString() : null;

      if (!parentId) {
        roots.push(node);
        return;
      }

      const parentNode = map.get(parentId);
      if (!parentNode) {
        roots.push(node);
        return;
      }

      parentNode.children.push(node);
    });

    return roots;
  }

  private collectDescendantCommentIds(comments: any[], rootCommentId: string) {
    const childrenByParent = new Map<string, string[]>();

    comments.forEach((comment) => {
      const parentId = comment.parentCommentId ? comment.parentCommentId.toString() : null;
      if (!parentId) {
        return;
      }

      if (!childrenByParent.has(parentId)) {
        childrenByParent.set(parentId, []);
      }
      childrenByParent.get(parentId)!.push(comment._id.toString());
    });

    const toDelete = new Set<string>([rootCommentId]);
    const queue = [rootCommentId];

    while (queue.length > 0) {
      const currentId = queue.shift() as string;
      const children = childrenByParent.get(currentId) || [];
      children.forEach((childId) => {
        if (!toDelete.has(childId)) {
          toDelete.add(childId);
          queue.push(childId);
        }
      });
    }

    return toDelete;
  }

  async createPost(authorId: Types.ObjectId, content?: string, media?: PostMediaInput[]) {
    if (!content && (!media || media.length === 0)) {
      throw new Error("Post phai co content hoac media");
    }

    const safeMedia = (media || []).map((item) => ({
      bucket: item.bucket,
      objectKey: item.objectKey,
      mimeType: item.mimeType,
      size: item.size,
    }));

    const post = await this.postRepository.create({
      authorId,
      content,
      media: safeMedia,
    });

    const populated = await this.postRepository.findById(post._id.toString());
    return this.formatPost(populated as any);
  }

  async getFeed(userId: Types.ObjectId, page = 1, limit = 20) {
    const friendships = await Friend.find({
      $or: [{ userA: userId }, { userB: userId }],
    }).select("userA userB");

    const preferredIds = new Set<string>([userId.toString()]);

    friendships.forEach((friendship: any) => {
      const friendId =
        friendship.userA.toString() === userId.toString()
          ? friendship.userB.toString()
          : friendship.userA.toString();
      preferredIds.add(friendId);
    });

    const preferredAuthorIds = Array.from(preferredIds).map((id) => new Types.ObjectId(id));
    const safeLimit = Math.max(1, Math.min(limit, 50));
    const safePage = Math.max(1, page);
    const skip = (safePage - 1) * safeLimit;

    const [items, total] = await Promise.all([
      this.postRepository.findFeed(preferredAuthorIds, skip, safeLimit),
      this.postRepository.countAll(),
    ]);

    return {
      items: items.map((item: any) => this.formatPost(item)),
      page: safePage,
      limit: safeLimit,
      total,
      hasMore: skip + items.length < total,
    };
  }

  async getPostById(postId: string) {
    const post = await this.postRepository.findById(postId);
    if (!post) {
      throw new Error("Post khong ton tai");
    }

    return this.formatPost(post as any);
  }

  async updatePost(postId: string, requesterId: Types.ObjectId, payload: UpdatePostPayload) {
    const safeUploaded = (payload.uploadedMedia || []).map((item) => ({
      bucket: item.bucket,
      objectKey: item.objectKey,
      mimeType: item.mimeType,
      size: item.size,
    }));

    if (!payload.hasContentField && !payload.hasMediaField && safeUploaded.length === 0) {
      throw new Error("Khong co du lieu cap nhat");
    }

    const post = await this.postRepository.findRawById(postId);
    if (!post) {
      throw new Error("Post khong ton tai");
    }

    if (post.authorId.toString() !== requesterId.toString()) {
      throw new Error("Khong co quyen chinh sua post nay");
    }

    const currentContent = typeof post.content === "string" ? post.content : "";
    const currentMedia = (post.media || []).map((item: any) => ({
      bucket: item.bucket,
      objectKey: item.objectKey,
      mimeType: item.mimeType,
      size: item.size,
    }));

    const nextContent = payload.hasContentField
      ? String(payload.content || "").trim()
      : currentContent;
    const baseMedia = payload.hasMediaField
      ? (payload.mediaFromBody || []).map((item) => ({
        bucket: item.bucket,
        objectKey: item.objectKey,
        mimeType: item.mimeType,
        size: item.size,
      }))
      : currentMedia;
    const nextMedia = [...baseMedia, ...safeUploaded];

    if (!nextContent && nextMedia.length === 0) {
      throw new Error("Post phai co content hoac media");
    }

    post.content = nextContent || undefined;
    post.media = nextMedia as any;

    await this.postRepository.save(post);

    const updated = await this.postRepository.findById(postId);
    if (!updated) {
      throw new Error("Post khong ton tai");
    }

    return this.formatPost(updated as any);
  }

  async deletePost(postId: string, requesterId: Types.ObjectId) {
    const post = await this.postRepository.findById(postId);

    if (!post) {
      throw new Error("Post khong ton tai");
    }

    if (post.authorId._id.toString() !== requesterId.toString()) {
      throw new Error("Khong co quyen xoa post nay");
    }

    await this.postRepository.deleteById(postId);
  }

  async toggleLike(postId: string, userId: Types.ObjectId) {
    const rawPost = await this.postRepository.findRawById(postId);
    if (!rawPost) {
      throw new Error("Post khong ton tai");
    }

    const hasLikedBefore = (rawPost.likes || []).some((id: Types.ObjectId) => id.toString() === userId.toString());

    const post = await this.postRepository.toggleLike(postId, userId);

    if (!post) {
      throw new Error("Post khong ton tai");
    }

    const isLikedNow = post.likes.some((id: Types.ObjectId) => id.toString() === userId.toString());
    const postAuthorId = rawPost.authorId.toString();

    if (!hasLikedBefore && isLikedNow && postAuthorId !== userId.toString()) {
      await this.notificationService.createNotification({
        recipientId: new Types.ObjectId(postAuthorId),
        actorId: userId,
        type: "POST_LIKED",
        title: "Bai viet cua ban co luot thich moi",
        body: "Co nguoi vua thich bai viet cua ban.",
        entityType: "post",
        entityId: postId,
      });
    }

    const populated = await this.postRepository.findById(postId);
    return this.formatPost(populated as any);
  }

  async addComment(postId: string, authorId: Types.ObjectId, content: string, parentCommentId?: string) {
    const normalized = (content || "").trim();
    if (!normalized) {
      throw new Error("Noi dung comment khong duoc de trong");
    }

    const rawPost = await this.postRepository.findRawById(postId);
    if (!rawPost) {
      throw new Error("Post khong ton tai");
    }

    let parentAuthorId: string | null = null;

    if (parentCommentId) {
      const parentComment = (rawPost.comments || []).find(
        (comment: any) => comment._id.toString() === parentCommentId,
      );

      const parentExists = !!parentComment;

      if (!parentExists) {
        throw new Error("Comment cha khong ton tai");
      }

      parentAuthorId = parentComment.authorId.toString();
    }

    const post = await this.postRepository.addComment(postId, authorId, normalized, parentCommentId);
    if (!post) {
      throw new Error("Post khong ton tai");
    }

    const latestComment = (post.comments || [])[post.comments.length - 1];
    if (!latestComment) {
      throw new Error("Khong the tao comment");
    }

    const postAuthorId = rawPost.authorId.toString();
    const actorId = authorId;

    if (postAuthorId !== authorId.toString()) {
      await this.notificationService.createNotification({
        recipientId: new Types.ObjectId(postAuthorId),
        actorId,
        type: "POST_COMMENTED",
        title: "Bai viet cua ban co binh luan moi",
        body: "Co nguoi vua binh luan bai viet cua ban.",
        entityType: "post",
        entityId: postId,
        metadata: {
          commentId: latestComment._id.toString(),
        },
      });
    }

    if (
      parentCommentId &&
      parentAuthorId &&
      parentAuthorId !== authorId.toString() &&
      parentAuthorId !== postAuthorId
    ) {
      await this.notificationService.createNotification({
        recipientId: new Types.ObjectId(parentAuthorId),
        actorId,
        type: "COMMENT_REPLIED",
        title: "Comment cua ban co phan hoi moi",
        body: "Co nguoi vua tra loi comment cua ban.",
        entityType: "comment",
        entityId: parentCommentId,
        metadata: {
          postId,
          replyCommentId: latestComment._id.toString(),
        },
      });
    }

    return this.formatComment(latestComment as any);
  }

  async getComments(postId: string) {
    const result = await this.postRepository.getComments(postId);
    if (!result) {
      throw new Error("Post khong ton tai");
    }

    const comments = ((result as any).comments || []).map((comment: any) => this.formatComment(comment));
    const commentTree = this.buildCommentTree(comments);

    return {
      comments: commentTree,
      flatComments: comments,
      commentsCount: (result as any).commentsCount || comments.length,
    };
  }

  async deleteComment(postId: string, commentId: string, requesterId: Types.ObjectId) {
    const post = await this.postRepository.findRawById(postId);
    if (!post) {
      throw new Error("Post khong ton tai");
    }

    const targetComment = (post.comments || []).find((comment: any) => comment._id.toString() === commentId);
    if (!targetComment) {
      throw new Error("Comment khong ton tai");
    }

    const isCommentOwner = targetComment.authorId.toString() === requesterId.toString();
    const isPostOwner = post.authorId.toString() === requesterId.toString();

    if (!isCommentOwner && !isPostOwner) {
      throw new Error("Khong co quyen xoa comment nay");
    }

    const idsToDelete = this.collectDescendantCommentIds(post.comments || [], commentId);

    const before = (post.comments || []).length;
    post.comments = post.comments.filter((comment: any) => !idsToDelete.has(comment._id.toString())) as any;
    const removedCount = before - (post.comments || []).length;
    post.commentsCount = Math.max(0, (post.commentsCount || 0) - removedCount);

    await this.postRepository.save(post);
  }
}
