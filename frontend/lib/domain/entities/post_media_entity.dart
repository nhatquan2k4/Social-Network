class PostMediaEntity {
  final String bucket;
  final String objectKey;
  final String? mediaUrl;
  final String mimeType;
  final int size;

  PostMediaEntity({
    required this.bucket,
    required this.objectKey,
    this.mediaUrl,
    required this.mimeType,
    required this.size,
  });
}
