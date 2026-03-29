import 'package:flutter/material.dart';

class ChatBlockBottomSheet extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final VoidCallback onConfirm;

  const ChatBlockBottomSheet({
    super.key,
    required this.displayName,
    required this.avatarAssetPath,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCD1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 44,
            foregroundImage: AssetImage(avatarAssetPath),
          ),
          const SizedBox(height: 14),
          Text(
            'Chặn $displayName?',
            style: const TextStyle(
              fontSize: 39 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mọi tài khoản khác mà họ có thể sở hữu hoặc tạo trong tương lai\nđều bị chặn. Bạn có thể bỏ chặn họ bất cứ lúc nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF737378),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const _BlockPoint(
            icon: Icons.hide_source,
            text:
                'Họ sẽ không thể nhắn tin cho bạn hay tìm thấy\nđược trang cá nhân/nội dung của bạn.',
          ),
          const SizedBox(height: 12),
          const _BlockPoint(
            icon: Icons.notifications_off_outlined,
            text: 'Họ sẽ không được thông báo là bạn đã chặn họ.',
          ),
          const SizedBox(height: 18),
          _sheetButton(
            color: const Color(0xFF1689F6),
            text: 'Chặn',
            textColor: Colors.white,
            onTap: onConfirm,
          ),
          const SizedBox(height: 10),
          _sheetButton(
            color: const Color(0xFFF10D0D),
            text: 'Hủy',
            textColor: Colors.white,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _sheetButton({
    required Color color,
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 27 / 2),
        ),
      ),
    );
  }
}

class _BlockPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BlockPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28 / 1.2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.5, height: 1.45),
          ),
        ),
      ],
    );
  }
}
