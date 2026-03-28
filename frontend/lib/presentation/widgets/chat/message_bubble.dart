import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final bool showAvatar;
  final String friendName;
  final String friendAvatarAssetPath;
  final Color friendAvatarColor;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    this.showAvatar = true,
    required this.friendName,
    this.friendAvatarAssetPath = 'assets/images/logo1.jpg',
    this.friendAvatarColor = const Color(0xFF7A6256),
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.705;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar for friend messages
          if (!isMe && showAvatar) ...[
            Container(
              width: 31,
              height: 31,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCACBD1), width: 1),
              ),
              child: CircleAvatar(
                backgroundColor: friendAvatarColor,
                foregroundImage: AssetImage(friendAvatarAssetPath),
                child: Text(
                  friendName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (!isMe && !showAvatar) const SizedBox(width: 36),

          // Message bubble
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF58E48F) : const Color(0xFFE3E3E6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14.5,
                  height: 1.24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Spacing for my messages
          if (isMe) const SizedBox(width: 3),
        ],
      ),
    );
  }
}
