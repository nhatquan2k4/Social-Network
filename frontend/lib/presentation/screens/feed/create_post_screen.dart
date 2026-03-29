import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();

  List<XFile> _selectedImages = const [];
  int _currentImageIndex = 0;
  bool _isPickingImages = false;

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty ||
        _selectedImages.isNotEmpty;
  }

  Future<void> _pickFromGallery() async {
    if (_isPickingImages) return;

    setState(() => _isPickingImages = true);
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (images.isEmpty || !mounted) {
        return;
      }

      setState(() {
        _selectedImages = images;
        _currentImageIndex = 0;
      });
      _pageController.jumpToPage(0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong the chon anh tu thu vien')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  Future<void> _pickFromCamera() async {
    if (_isPickingImages) return;

    setState(() => _isPickingImages = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImages = <XFile>[..._selectedImages, image];
        _currentImageIndex = _selectedImages.length - 1;
      });
      _pageController.jumpToPage(_currentImageIndex);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Khong the mo camera')));
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    final nextImages = List<XFile>.from(_selectedImages)..removeAt(index);

    setState(() {
      _selectedImages = nextImages;
      if (_selectedImages.isEmpty) {
        _currentImageIndex = 0;
      } else if (_currentImageIndex >= _selectedImages.length) {
        _currentImageIndex = _selectedImages.length - 1;
      }
    });

    if (_selectedImages.isNotEmpty) {
      _pageController.jumpToPage(_currentImageIndex);
    }
  }

  Future<void> _submitPost() async {
    final feedProvider = context.read<FeedProvider>();
    if (feedProvider.isCreatingPost || !_canSubmit) {
      return;
    }

    final success = await feedProvider.createPost(
      content: _captionController.text,
      imagePaths: _selectedImages
          .map((item) => item.path)
          .toList(growable: false),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    if (feedProvider.requiresAuth) {
      return;
    }

    final message = feedProvider.error;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      feedProvider.clearError();
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tao bai viet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Consumer<FeedProvider>(
            builder: (context, feedProvider, _) {
              return TextButton(
                onPressed: (feedProvider.isCreatingPost || !_canSubmit)
                    ? null
                    : _submitPost,
                child: feedProvider.isCreatingPost
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Dang',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaSection(hasImages),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _captionController,
                    minLines: 5,
                    maxLines: 10,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Viet caption cho bai viet...'
                          '\nGoi y: them hashtag de tiep can tot hon.',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isPickingImages ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Thu vien'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isPickingImages ? null : _pickFromCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(bool hasImages) {
    if (!hasImages) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.collections_outlined,
              size: 46,
              color: Colors.black38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Them anh/video cho bai viet',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _isPickingImages ? null : _pickFromGallery,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Chon tu thu vien'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _selectedImages.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    if (kIsWeb) {
                      return Image.network(image.path, fit: BoxFit.cover);
                    }
                    return Image.file(File(image.path), fit: BoxFit.cover);
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => _removeImageAt(_currentImageIndex),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (_selectedImages.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_selectedImages.length, (index) {
                        final isActive = index == _currentImageIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: isActive ? 16 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return InkWell(
                  onTap: _isPickingImages ? null : _pickFromGallery,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: const Icon(Icons.add, color: Colors.black54),
                  ),
                );
              }

              final image = _selectedImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _currentImageIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  width: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _currentImageIndex == index
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(image.path, fit: BoxFit.cover)
                        : Image.file(File(image.path), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
