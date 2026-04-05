import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/url_normalizer.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/domain/entities/post_media_entity.dart';
import 'package:image_picker/image_picker.dart';

class EditPostDraft {
  const EditPostDraft({
    required this.content,
    required this.retainedMedia,
    required this.newImagePaths,
  });

  final String content;
  final List<PostMediaEntity> retainedMedia;
  final List<String> newImagePaths;
}

Future<EditPostDraft?> showEditPostBottomSheet({
  required BuildContext context,
  required PostEntity post,
}) {
  return showModalBottomSheet<EditPostDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditPostBottomSheet(post: post),
  );
}

class _EditPostBottomSheet extends StatefulWidget {
  const _EditPostBottomSheet({required this.post});

  final PostEntity post;

  @override
  State<_EditPostBottomSheet> createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<_EditPostBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _contentController;

  late List<PostMediaEntity> _retainedMedia;
  List<XFile> _newImages = const [];
  bool _isPickingImages = false;

  bool get _canSubmit {
    return _contentController.text.trim().isNotEmpty ||
        _retainedMedia.isNotEmpty ||
        _newImages.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content ?? '');
    _retainedMedia = List<PostMediaEntity>.from(widget.post.media);
  }

  Future<void> _pickFromGallery() async {
    if (_isPickingImages) return;

    setState(() => _isPickingImages = true);
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1920,
      );

      if (images.isEmpty || !mounted) return;

      setState(() {
        _newImages = <XFile>[..._newImages, ...images];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ảnh từ thư viện')),
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

      if (image == null || !mounted) return;

      setState(() {
        _newImages = <XFile>[..._newImages, image];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở camera')));
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeExistingMediaAt(int index) {
    if (index < 0 || index >= _retainedMedia.length) return;
    setState(() {
      _retainedMedia = List<PostMediaEntity>.from(_retainedMedia)
        ..removeAt(index);
    });
  }

  void _removeNewImageAt(int index) {
    if (index < 0 || index >= _newImages.length) return;
    setState(() {
      _newImages = List<XFile>.from(_newImages)..removeAt(index);
    });
  }

  void _submit() {
    final content = _contentController.text.trim();
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bài viết cần có nội dung hoặc ít nhất một ảnh'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      EditPostDraft(
        content: content,
        retainedMedia: List<PostMediaEntity>.from(_retainedMedia),
        newImagePaths: _newImages
            .map((item) => item.path)
            .where((path) => path.trim().isNotEmpty)
            .toList(growable: false),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaCount = _retainedMedia.length + _newImages.length;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6D8DE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Text(
                  'Chỉnh sửa bài viết',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  mediaCount > 0
                      ? 'Đang có $mediaCount ảnh (bao gồm ảnh cũ và ảnh mới).'
                      : 'Bạn có thể sửa nội dung hoặc thêm ảnh mới.',
                  style: const TextStyle(
                    color: Color(0xFF6F7280),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _contentController,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1500,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Nhập nội dung mới...',
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ảnh hiện tại',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildExistingMediaSection(),
                const SizedBox(height: 10),
                const Text(
                  'Ảnh mới thêm',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildNewMediaSection(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPickingImages ? null : _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Thư viện'),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExistingMediaSection() {
    if (_retainedMedia.isEmpty) {
      return _emptyMediaBox('Hiện không giữ ảnh cũ nào');
    }

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _retainedMedia.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final media = _retainedMedia[index];
          final mediaUrl = (media.mediaUrl ?? '').normalizeClientUrl();

          return _mediaTile(
            label: 'Ảnh cũ',
            onRemove: () => _removeExistingMediaAt(index),
            child: mediaUrl.isNotEmpty
                ? Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),
          );
        },
      ),
    );
  }

  Widget _buildNewMediaSection() {
    if (_newImages.isEmpty) {
      return _emptyMediaBox('Chưa có ảnh mới');
    }

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _newImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final image = _newImages[index];
          return _mediaTile(
            label: 'Ảnh mới',
            onRemove: () => _removeNewImageAt(index),
            child: kIsWeb
                ? Image.network(image.path, fit: BoxFit.cover)
                : Image.file(File(image.path), fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _emptyMediaBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF6F7280), fontSize: 13),
      ),
    );
  }

  Widget _mediaTile({
    required String label,
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF0F2F5),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Colors.black45),
    );
  }
}
