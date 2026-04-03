import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/presentation/screens/auth/fogot_screen.dart';
import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/auth/register_screen.dart';
import 'package:frontend/presentation/screens/auth/welcome_screen.dart';
import 'package:frontend/presentation/screens/chat/messages_screen.dart';
import 'package:frontend/presentation/screens/explore/explore_screen.dart';
import 'package:frontend/presentation/screens/feed/create_post_screen.dart';
import 'package:frontend/presentation/screens/feed/feed_screen.dart';
import 'package:frontend/presentation/screens/profile/profile_screen.dart';
import 'package:frontend/presentation/screens/reels/reels_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _buildMaterialRoute(
          settings: settings,
          child: const WelcomeScreen(),
        );
      case AppRoutes.login:
        return _buildMaterialRoute(
          settings: settings,
          child: const LoginScreen(),
        );
      case AppRoutes.register:
        return _buildMaterialRoute(
          settings: settings,
          child: const RegisterScreen(),
        );
      case AppRoutes.fogot:
        return _buildMaterialRoute(
          settings: settings,
          child: const FogotScreen(),
        );
      case AppRoutes.postsCreate:
        return _buildMaterialRoute(
          settings: settings,
          child: const CreatePostScreen(),
        );
      case AppRoutes.postsFeed:
        return _buildBottomTabRoute(
          settings: settings,
          child: const FeedScreen(),
        );
      case AppRoutes.explore:
        return _buildBottomTabRoute(
          settings: settings,
          child: const ExploreScreen(),
        );
      case AppRoutes.reels:
        return _buildBottomTabRoute(
          settings: settings,
          child: const ReelsScreen(),
        );
      case AppRoutes.messages:
        return _buildBottomTabRoute(
          settings: settings,
          child: const MessagesScreen(),
        );
      case AppRoutes.profile:
        return _buildBottomTabRoute(
          settings: settings,
          child: const ProfileScreen(),
        );
      default:
        return _buildMaterialRoute(
          settings: settings,
          child: const WelcomeScreen(),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildMaterialRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }

  static PageRouteBuilder<dynamic> _buildBottomTabRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: pageChild,
        );
      },
    );
  }
}
