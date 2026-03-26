import { Request, Response } from "express";
import { MediaPurpose } from "../config/minio";
import { MediaService } from "../services/mediaService";

const mediaService = new MediaService();

const VALID_PURPOSES: MediaPurpose[] = ["post", "message", "avatar"];

export const uploadMedia = async (req: Request, res: Response) => {
  try {
    const purpose = (req.body?.purpose || req.query?.purpose || "post") as MediaPurpose;

    if (!VALID_PURPOSES.includes(purpose)) {
      return res.status(400).json({ message: "purpose khong hop le" });
    }

    const files = (req.files || []) as Express.Multer.File[];

    if (!files.length) {
      return res.status(400).json({ message: "Khong tim thay file upload" });
    }

    const ownerId = req.user!._id.toString();

    const uploaded = await mediaService.uploadFiles(files, purpose, ownerId);

    return res.status(201).json({
      message: "Upload media thanh cong",
      data: uploaded,
    });
  } catch (error: any) {
    console.error("Loi upload media", error);
    if (
      error.message === "Dinh dang file khong duoc ho tro" ||
      error.message === "Kich thuoc file vuot qua gioi han" ||
      error.message === "So luong file vuot qua gioi han"
    ) {
      return res.status(400).json({ message: error.message });
    }

    return res.status(500).json({ message: "Loi server" });
  }
};
