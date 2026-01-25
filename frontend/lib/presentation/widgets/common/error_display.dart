import 'package:flutter/material.dart';

/// Reusable error display widget with retry button
///
/// Usage:
/// ```dart
/// ErrorDisplay(message: 'Lỗi kết nối')
/// ErrorDisplay(
///   message: 'Không tải được dữ liệu',
///   onRetry: () => provider.fetchData(),
/// )
/// ErrorDisplay.network(onRetry: () => retry())
/// ```
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? retryButtonText;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryButtonText,
  });

  /// Network error preset
  const ErrorDisplay.network({super.key, this.onRetry, this.retryButtonText})
    : message = 'Lỗi kết nối mạng\nVui lòng kiểm tra kết nối và thử lại',
      icon = Icons.wifi_off;

  /// Server error preset
  const ErrorDisplay.server({super.key, this.onRetry, this.retryButtonText})
    : message = 'Lỗi server\nVui lòng thử lại sau',
      icon = Icons.cloud_off;

  /// Not found error preset
  const ErrorDisplay.notFound({super.key, this.onRetry, this.retryButtonText})
    : message = 'Không tìm thấy dữ liệu',
      icon = Icons.search_off;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
