import 'dart:ui';

import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({super.key, this.currentIndex = 0, this.onTap});

  static const _items = [
    Icons.home_outlined,
    Icons.search,
    Icons.smart_display_outlined,
    Icons.send_outlined,
  ];

  static const _activeColor = Color(0xFF141414);
  static const _inactiveColor = Color(0xFF383C44);
  static const _chatPillColor = Color(0xFFD9E0F8);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.58),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x22000000),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navIcon(index: 0, icon: _items[0]),
                  _navIcon(index: 1, icon: _items[1]),
                  _navIcon(index: 2, icon: _items[2]),
                  _navIcon(index: 3, icon: _items[3], isChatTab: true),
                  _profileTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileTab() {
    final isSelected = currentIndex == 4;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => onTap?.call(4),
      child: Container(
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFF7B5C4A),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: isSelected
                ? const Color(0xFF5B3F31)
                : const Color(0xFF8D6B56),
            child: const Text(
              'h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
    required int index,
    required IconData icon,
    bool isChatTab = false,
  }) {
    final isSelected = index == currentIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => onTap?.call(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected && isChatTab
              ? _chatPillColor
              : Colors.white.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected && isChatTab
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.56),
            width: 1.1,
          ),
          boxShadow: isSelected && isChatTab
              ? [
                  BoxShadow(
                    color: const Color(0x26000000),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected && isChatTab)
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            Icon(
              icon,
              size: isChatTab ? 31 : 34,
              color: isSelected ? _activeColor : _inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}
