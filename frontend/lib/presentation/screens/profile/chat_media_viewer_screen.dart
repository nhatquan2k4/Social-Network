import 'package:flutter/material.dart';

String mediaHeroTag(String assetPath, int index) {
  return 'chat_media_${assetPath.hashCode}_$index';
}

class ChatMediaViewerScreen extends StatefulWidget {
  final String displayName;
  final String avatarAssetPath;
  final List<String> mediaAssets;
  final int initialIndex;

  const ChatMediaViewerScreen({
    super.key,
    required this.displayName,
    required this.avatarAssetPath,
    required this.mediaAssets,
    this.initialIndex = 0,
  });

  @override
  State<ChatMediaViewerScreen> createState() => _ChatMediaViewerScreenState();
}

class _ChatMediaViewerScreenState extends State<ChatMediaViewerScreen> {
  late final PageController _pageController;
  final TransformationController _zoomController = TransformationController();

  late int _currentIndex;
  double _dragOffsetY = 0;
  bool _isDraggingDismiss = false;

  bool get _isZoomed => _zoomController.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.mediaAssets.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dismissProgress = (_dragOffsetY / 220).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Color.lerp(
        const Color(0xFFF2F2F4),
        Colors.black,
        dismissProgress,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Opacity(
              opacity: 1 - dismissProgress * 0.5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      radius: 14,
                      foregroundImage: AssetImage(widget.avatarAssetPath),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Đang hoạt động',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF87878D),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send_outlined),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragStart: (_) {
                  if (_isZoomed) return;
                  setState(() => _isDraggingDismiss = true);
                },
                onVerticalDragUpdate: (details) {
                  if (_isZoomed) return;
                  setState(() {
                    _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(
                      0,
                      300,
                    );
                  });
                },
                onVerticalDragEnd: (_) {
                  if (_isZoomed) return;
                  if (_dragOffsetY > 120) {
                    Navigator.pop(context);
                    return;
                  }
                  setState(() {
                    _isDraggingDismiss = false;
                    _dragOffsetY = 0;
                  });
                },
                child: AnimatedContainer(
                  duration: _isDraggingDismiss
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _dragOffsetY, 0),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.mediaAssets.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentIndex = value;
                        _dragOffsetY = 0;
                        _isDraggingDismiss = false;
                      });
                      _zoomController.value = Matrix4.identity();
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Hero(
                            tag: mediaHeroTag(widget.mediaAssets[index], index),
                            child: InteractiveViewer(
                              transformationController: _zoomController,
                              minScale: 1,
                              maxScale: 4,
                              panEnabled: true,
                              child: Image.asset(
                                widget.mediaAssets[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 1 - dismissProgress * 0.7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0D0D4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 21),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Trả lời...',
                          style: TextStyle(
                            color: Color(0xFF7A7A80),
                            fontSize: 30 / 2,
                          ),
                        ),
                      ),
                      const Icon(Icons.mic_none, size: 25),
                      const SizedBox(width: 10),
                      const Icon(Icons.photo_library_outlined, size: 24),
                      const SizedBox(width: 10),
                      const Icon(Icons.link, size: 24),
                    ],
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 1 - dismissProgress * 0.7,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_currentIndex + 1}/${widget.mediaAssets.length}',
                  style: const TextStyle(
                    color: Color(0xFF87878D),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
