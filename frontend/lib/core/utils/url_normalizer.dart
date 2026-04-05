import 'package:flutter/foundation.dart';

/// Normalizes backend-hosted URLs so they are reachable from each client runtime.
///
/// Example: Android emulator cannot access host machine via localhost,
/// so `localhost` / `127.0.0.1` are rewritten to `10.0.2.2`.
String normalizeClientNetworkUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return trimmed;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      return uri.replace(host: '10.0.2.2').toString();
    }
  }

  return trimmed;
}

extension ClientUrlNormalization on String {
  String normalizeClientUrl() => normalizeClientNetworkUrl(this);
}
