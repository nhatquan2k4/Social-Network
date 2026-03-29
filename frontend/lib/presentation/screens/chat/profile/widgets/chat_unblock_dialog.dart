import 'package:flutter/material.dart';

class ChatUnblockDialog extends StatelessWidget {
  final String displayName;
  final VoidCallback onConfirm;

  const ChatUnblockDialog({
    super.key,
    required this.displayName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF4F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bỏ chặn $displayName?',
              style: const TextStyle(
                fontSize: 33 / 1.7,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Từ giờ, $displayName và các tài khoản khác mà\nhọ sở hữu hoặc tạo có thể yêu cầu theo dõi và nhắn tin\ncho bạn trên Mochi. Họ sẽ không được thông báo là bạn\nđã bỏ chặn họ.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF707077),
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onConfirm,
              child: const Text(
                'Bỏ chặn',
                style: TextStyle(
                  color: Color(0xFFE60000),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Color(0xFF1E1E23),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
