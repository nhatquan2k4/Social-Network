import { Request, Response, NextFunction } from 'express';
import { ConversationRepository } from '../../routes/conversations/shared/conversations.repo.js';
import {
	BlockRepository,
	FriendRepository,
} from '../../routes/friends/shared/friends.repo.js';

const blockRepository = new BlockRepository();
const conversationRepository = new ConversationRepository();
const friendRepository = new FriendRepository();

// Helper function to ensure consistent ordering of user IDs
const pair = (userA: string, userB: string): [string, string] => {
	return userA < userB ? [userA, userB] : [userB, userA];
};

export const checkFriendship = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const me = req.user!._id.toString();
		const type = req.body?.type;
		const memberIds = Array.isArray(req.body?.memberIds)
			? req.body.memberIds
			: [];

		// Lay recipientId tu body, query, hoac memberIds[0] neu type la direct
		let recipientId = req.body?.recipientId ?? req.query?.recipientId ?? null;

		// Neu khong co recipientId nhung co memberIds va type la direct
		if (
			!recipientId &&
			req.body?.type === "direct" &&
			req.body?.memberIds?.[0]
		) {
			recipientId = req.body.memberIds[0];
		}

		if (!recipientId) {
			if (type === "group") {
				if (memberIds.length === 0) {
					return res
						.status(400)
						.json({ message: "MemberIds khong duoc trong" });
				}

				const invalidMembers: string[] = [];
				for (const memberId of memberIds) {
					const memberText = (memberId ?? "").toString().trim();
					if (!memberText || memberText === me) {
						continue;
					}

					const [userA, userB] = pair(me, memberText);
					const isFriend = await friendRepository.findByUsers(userA, userB);
					if (!isFriend) {
						invalidMembers.push(memberText);
					}
				}

				if (invalidMembers.length > 0) {
					return res
						.status(403)
						.json({ message: "Thanh vien khong phai ban be" });
				}

				return next();
			}

			return res
				.status(400)
				.json({ message: "Can cung cap recipientId hoac memberIds" });
		}

		if (recipientId) {
			const [userA, userB] = pair(me, recipientId as string);

			const blockRelation = await blockRepository.findBetweenUsers(
				me,
				recipientId as string,
			);

			if (blockRelation) {
				return res.status(403).json({
					message: "Khong the thuc hien hanh dong nay vi da co quan he block",
				});
			}

			const isFriend = await friendRepository.findByUsers(userA, userB);

			if (!isFriend) {
				return res.status(403).json({ message: "Hai nguoi khong phai ban be" });
			}

			return next();
		}
	} catch (error) {
		console.error(error);
		return res.status(500).json({ message: "Loi server" });
	}
};

export const checkGroupMembership = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { conversationId } = req.body;
		const userId = req.user!._id;

		const conversation = await conversationRepository.findById(conversationId);

		if (!conversation) {
			return res
				.status(404)
				.json({ message: "Khong tim thay cuoc tro chuyen" });
		}

		const isMember = conversation.participants.some(
			(p: any) => p.userId.toString() === userId.toString(),
		);

		if (!isMember) {
			return res.status(403).json({ message: "Ban khong o trong group nay." });
		}

		req.conversation = conversation;

		next();
	} catch (error) {
		console.error("Loi checkGroupMembership:", error);
		return res.status(500).json({ message: "Loi he thong" });
	}
};

export const checkConversationMembership = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		// Lay conversationId tu params hoac body
		const conversationId = req.params.conversationId || req.body.conversationId;
		const userId = req.user!._id;

		if (!conversationId) {
			return res.status(400).json({ message: "Thieu conversationId" });
		}

		const conversation = await conversationRepository.findById(conversationId);

		if (!conversation) {
			return res
				.status(404)
				.json({ message: "Khong tim thay cuoc tro chuyen" });
		}

		const isMember = conversation.participants.some(
			(p: any) => p.userId.toString() === userId.toString(),
		);

		if (!isMember) {
			return res
				.status(403)
				.json({ message: "Ban khong co quyen truy cap cuoc tro chuyen nay" });
		}

		req.conversation = conversation;
		next();
	} catch (error) {
		console.error("Loi checkConversationMembership:", error);
		return res.status(500).json({ message: "Loi he thong" });
	}
};
