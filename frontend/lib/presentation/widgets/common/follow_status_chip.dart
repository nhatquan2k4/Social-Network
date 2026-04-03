import 'package:flutter/material.dart';

class FollowStatusChip extends StatelessWidget {
  const FollowStatusChip({
    super.key,
    required this.isFollowing,
    required this.followingText,
    required this.followText,
    this.onTap,
  });

  final bool isFollowing;
  final String followingText;
  final String followText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isFollowing
        ? const Color(0xFFE9E9EB)
        : const Color(0xFF1689F6);
    final textColor = isFollowing ? const Color(0xFF202025) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isFollowing ? followingText : followText,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
