import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    // Android emulator cannot reach host services via localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001/api';
    }
    return 'http://localhost:3001/api';
  }

  static const String login = '/auth/login';
  static const String friends = '/friends';
  static const String profile = '/users/me';
  static const String conversations = '/conversations';
  static const String messages = '/messages/direct';
  static const String groups = '/messages/group';
}
