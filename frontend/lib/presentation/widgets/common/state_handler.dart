import 'package:flutter/material.dart';
import 'loading_indicator.dart';
import 'error_display.dart';
import 'empty_state.dart';

/// Generic state handler widget that handles loading, error, empty, and success states
///
/// Usage:
/// ```dart
/// StateHandler<List<Friend>>(
///   isLoading: provider.isLoading,
///   error: provider.error,
///   data: provider.friends,
///   onRetry: () => provider.fetchFriends(),
///   builder: (context, friends) {
///     return ListView.builder(
///       itemCount: friends.length,
///       itemBuilder: (context, index) => FriendTile(friends[index]),
///     );
///   },
/// )
/// ```
class StateHandler<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, T data) builder;

  // Customization
  final String? loadingMessage;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final bool Function(T data)? isEmpty;

  const StateHandler({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.builder,
    this.onRetry,
    this.loadingMessage,
    this.emptyMessage,
    this.emptyIcon,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return LoadingIndicator(message: loadingMessage);
    }

    // Error state
    if (error != null) {
      return ErrorDisplay(message: error!, onRetry: onRetry);
    }

    // No data
    if (data == null) {
      return EmptyState(
        message: emptyMessage ?? 'Không có dữ liệu',
        icon: emptyIcon ?? Icons.inbox_outlined,
      );
    }

    // Check if data is empty (for collections)
    if (isEmpty != null && isEmpty!(data!)) {
      return EmptyState(
        message: emptyMessage ?? 'Không có dữ liệu',
        icon: emptyIcon ?? Icons.inbox_outlined,
      );
    }

    // Success - show data
    return builder(context, data!);
  }
}

/// Extension to check if common collection types are empty
extension CollectionEmptyCheck on StateHandler {
  static bool isListEmpty<T>(List<T>? list) => list == null || list.isEmpty;
  static bool isMapEmpty<K, V>(Map<K, V>? map) => map == null || map.isEmpty;
}
