import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/chat/media/chat_media_viewer_screen.dart';

class ChatMediaGalleryScreen extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final List<String> mediaAssets;

  const ChatMediaGalleryScreen({
    super.key,
    required this.displayName,
    required this.avatarAssetPath,
    required this.mediaAssets,
  });

  @override
  Widget build(BuildContext context) {
    final items = mediaAssets.isNotEmpty
        ? mediaAssets
        : const ['assets/images/logo1.jpg'];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ảnh và video',
          style: TextStyle(
            color: Color(0xFF1F1F23),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatMediaViewerScreen(
                    displayName: displayName,
                    avatarAssetPath: avatarAssetPath,
                    mediaAssets: items,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Hero(
                tag: mediaHeroTag(items[index], index),
                child: Image.asset(items[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
