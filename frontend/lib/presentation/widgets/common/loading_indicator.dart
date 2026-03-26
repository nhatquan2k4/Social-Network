import 'package:flutter/material.dart';

/// Reusable loading indicator widget
///
/// Usage:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator(message: 'Đang tải...')
/// LoadingIndicator.small()
/// ```
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
  });

  /// Small loading indicator (size = 24)
  const LoadingIndicator.small({super.key, this.message, this.color})
    : size = 24.0;

  /// Large loading indicator (size = 60)
  const LoadingIndicator.large({super.key, this.message, this.color})
    : size = 60.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 40 ? 4.0 : 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
