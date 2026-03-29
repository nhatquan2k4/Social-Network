import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFDCE1E5)),
        ),
        child: Row(
          children: [
            _NavIconButton(
              icon: Icons.home_outlined,
              selected: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            _NavIconButton(
              icon: Icons.search,
              selected: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),
            _NavIconButton(
              icon: Icons.play_circle_outline,
              selected: currentIndex == 2,
              onTap: () => onTap?.call(2),
            ),
            _NavIconButton(
              customIcon: Image.asset(
                'assets/icons/send.png',
                width: 17,
                height: 17,
                color: Colors.black,
              ),
              selected: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onTap?.call(4),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == 4
                          ? const Color(0xFFD8E0F7)
                          : Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIconButton({
    this.icon,
    this.customIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = customIcon ?? Icon(icon, size: 23, color: Colors.black);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.04 : 1,
            duration: const Duration(milliseconds: 160),
            child: child,
          ),
        ),
      ),
    );
  }
}
