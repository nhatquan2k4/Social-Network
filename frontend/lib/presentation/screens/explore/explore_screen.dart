import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 52,
                  color: Color(0xFF2B2F36),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.exploreTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F23),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.featureInDevelopment,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6F737B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => BottomNavRouteController.handleTabSelection(
          context: context,
          currentIndex: _currentIndex,
          nextIndex: index,
          onIndexChanged: (next) => setState(() => _currentIndex = next),
          onUnsupportedDestination: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pageNotImplemented)),
            );
          },
        ),
      ),
    );
  }
}
