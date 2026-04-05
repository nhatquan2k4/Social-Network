import 'package:flutter/material.dart';

class FeedStoryData {
  const FeedStoryData({
    required this.label,
    required this.avatarUrl,
    this.isAsset = false,
    this.showPlusBadge = false,
  });

  final String label;
  final String avatarUrl;
  final bool isAsset;
  final bool showPlusBadge;
}

class FeedStoryItem extends StatelessWidget {
  const FeedStoryItem({required this.story, super.key});

  final FeedStoryData story;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = story.avatarUrl.isNotEmpty;

    Widget avatarChild;
    if (!hasAvatar) {
      avatarChild = const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFFDADADA),
        child: Icon(Icons.person, color: Color(0xFF8A8A90)),
      );
    } else if (story.isAsset) {
      avatarChild = CircleAvatar(
        radius: 25,
        foregroundImage: AssetImage(story.avatarUrl),
        backgroundColor: const Color(0xFFDADADA),
      );
    } else {
      avatarChild = CircleAvatar(
        radius: 25,
        foregroundImage: NetworkImage(story.avatarUrl),
        backgroundColor: const Color(0xFFDADADA),
      );
    }

    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF93A6B),
                      Color(0xFFFFA64D),
                      Color(0xFF8A3CFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(1.6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: avatarChild,
                ),
              ),
              if (story.showPlusBadge)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1689F6),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white, width: 1.4),
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            story.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF212126)),
          ),
        ],
      ),
    );
  }
}
