import { Request, Response } from "express";
import { PostService } from "./posts.service";
import { MediaService } from "../media/media.service";

const postService = new PostService();
const mediaService = new MediaService();

const parseManualMedia = (raw: any) => {
  if (!raw) {
    return [];
  }

  let value = raw;
  if (typeof raw === "string") {
    try {
      value = JSON.parse(raw);
    } catch {
      return [];
    }
  }

  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item: any) => item && typeof item === "object")
    .map((item: any) => ({
      bucket: typeof item.bucket === "string" ? item.bucket.trim() : "",
      objectKey: typeof item.objectKey === "string" ? item.objectKey.trim() : "",
      mimeType: typeof item.mimeType === "string" ? item.mimeType.trim() : "",
      size: Number(item.size),
    }))
    .filter((item: any) => item.bucket && item.objectKey && item.mimeType && Number.isFinite(item.size) && item.size > 0);
};

export const createPost = async (req: Request, res: Response) => {
  try {
    const authorId = req.user!._id;
    const { content, media } = req.body;

    const files = (req.files || []) as Express.Multer.File[];
    const uploadedMedia = files.length > 0
      ? await mediaService.uploadFiles(files, "post", authorId.toString())
      : [];

    const normalizedUploaded = uploadedMedia.map((item) => ({
      bucket: item.bucket,
      objectKey: item.objectKey,
      mimeType: item.mimeType,
      size: item.size,
    }));

    const manualMedia = parseManualMedia(media);
    const mergedMedia = [...manualMedia, ...normalizedUploaded];

    const post = await postService.createPost(authorId, content, mergedMedia);

    return res.status(201).json({ message: "Tao post thanh cong", data: post });
  } catch (error: any) {
    console.error("Loi khi tao post", error);
    if (error.message === "Post phai co content hoac media") {
      return res.status(400).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const getFeed = async (req: Request, res: Response) => {
  try {
    const userId = req.user!._id;
    const page = Number(req.query.page || "1");
    const limit = Number(req.query.limit || "20");

    const feed = await postService.getFeed(userId, page, limit);

    return res.status(200).json({ data: feed });
  } catch (error) {
    console.error("Loi khi lay feed", error);
    return res.status(500).json({ message: "Loi server" });
  }
};

export const getPostById = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const post = await postService.getPostById(postId as string);

    return res.status(200).json({ data: post });
  } catch (error: any) {
    console.error("Loi khi lay post", error);
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const updatePost = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const userId = req.user!._id;
    const hasContentField = Object.prototype.hasOwnProperty.call(req.body || {}, "content");
    const hasMediaField = Object.prototype.hasOwnProperty.call(req.body || {}, "media");
    const { content, media } = req.body;
    const files = (req.files || []) as Express.Multer.File[];

    if (!hasContentField && !hasMediaField && files.length === 0) {
      return res.status(400).json({ message: "Khong co du lieu cap nhat" });
    }

    if (hasMediaField && typeof media === "string") {
      try {
        JSON.parse(media);
      } catch {
        return res.status(400).json({ message: "Media JSON khong hop le" });
      }
    }

    const uploadedMedia = files.length > 0
      ? await mediaService.uploadFiles(files, "post", userId.toString())
      : [];

    const normalizedUploaded = uploadedMedia.map((item) => ({
      bucket: item.bucket,
      objectKey: item.objectKey,
      mimeType: item.mimeType,
      size: item.size,
    }));

    const manualMedia = hasMediaField ? parseManualMedia(media) : [];

    const updatedPost = await postService.updatePost(postId as string, userId, {
      content,
      hasContentField,
      mediaFromBody: hasMediaField ? manualMedia : undefined,
      hasMediaField,
      uploadedMedia: normalizedUploaded,
    });

    return res.status(200).json({ message: "Chinh sua post thanh cong", data: updatedPost });
  } catch (error: any) {
    console.error("Loi khi chinh sua post", error);
    if (error.message === "Khong co du lieu cap nhat" || error.message === "Post phai co content hoac media") {
      return res.status(400).json({ message: error.message });
    }
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    if (error.message === "Khong co quyen chinh sua post nay") {
      return res.status(403).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const deletePost = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const userId = req.user!._id;

    await postService.deletePost(postId as string, userId);

    return res.status(200).json({ message: "Xoa post thanh cong" });
  } catch (error: any) {
    console.error("Loi khi xoa post", error);
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    if (error.message === "Khong co quyen xoa post nay") {
      return res.status(403).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const toggleLikePost = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const userId = req.user!._id;

    const post = await postService.toggleLike(postId as string, userId);

    return res.status(200).json({ message: "Cap nhat like thanh cong", data: post });
  } catch (error: any) {
    console.error("Loi khi like/unlike post", error);
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const reportPost = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const { reason } = req.body;
    const userId = req.user!._id;

    await postService.reportPost(postId as string, userId, String(reason || ""));

    return res.status(200).json({ message: "Bao cao bai viet thanh cong" });
  } catch (error: any) {
    console.error("Loi khi bao cao bai viet", error);
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    if (error.message === "Ly do bao cao khong hop le") {
      return res.status(400).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const createPostComment = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const { content, parentCommentId } = req.body;
    const userId = req.user!._id;

    const comment = await postService.addComment(postId as string, userId, content, parentCommentId);

    return res.status(201).json({ message: "Tao comment thanh cong", data: comment });
  } catch (error: any) {
    console.error("Loi khi tao comment", error);
    if (error.message === "Noi dung comment khong duoc de trong") {
      return res.status(400).json({ message: error.message });
    }
    if (error.message === "Comment cha khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const getPostComments = async (req: Request, res: Response) => {
  try {
    const { postId } = req.params;
    const result = await postService.getComments(postId as string);

    return res.status(200).json({ data: result });
  } catch (error: any) {
    console.error("Loi khi lay comment", error);
    if (error.message === "Post khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};

export const deletePostComment = async (req: Request, res: Response) => {
  try {
    const { postId, commentId } = req.params;
    const userId = req.user!._id;

    await postService.deleteComment(postId as string, commentId as string, userId);

    return res.status(200).json({ message: "Xoa comment thanh cong" });
  } catch (error: any) {
    console.error("Loi khi xoa comment", error);
    if (error.message === "Post khong ton tai" || error.message === "Comment khong ton tai") {
      return res.status(404).json({ message: error.message });
    }
    if (error.message === "Khong co quyen xoa comment nay") {
      return res.status(403).json({ message: error.message });
    }
    return res.status(500).json({ message: "Loi server" });
  }
};
