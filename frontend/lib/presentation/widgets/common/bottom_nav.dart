import 'package:flutter/material.dart';

const bool _showBottomNavDebug = false;

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFFDDE5F8);
    const selectedFg = Color(0xFF1D1D1D);
    const unselectedFg = Color(0xFF303030);

    Widget navItem({
      required int index,
      required Widget icon,
      required bool selected,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => onTap?.call(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                width: selected ? 42 : 30,
                height: selected ? 42 : 30,
                decoration: BoxDecoration(
                  color: selected ? selectedBg : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: selected ? selectedFg : unselectedFg,
                    size: 22,
                  ),
                  child: Center(child: icon),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final routeName = ModalRoute.of(context)?.settings.name ?? 'null';

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showBottomNavDebug)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'route=$routeName | idx=$currentIndex | size=${mediaQuery.size.width.toStringAsFixed(0)}x${mediaQuery.size.height.toStringAsFixed(0)} | insetB=${mediaQuery.viewInsets.bottom.toStringAsFixed(1)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
            Row(
              children: [
                navItem(
                  index: 0,
                  selected: currentIndex == 0,
                  icon: const Icon(Icons.home_rounded),
                ),
                navItem(
                  index: 1,
                  selected: currentIndex == 1,
                  icon: const Icon(Icons.search_rounded),
                ),
                navItem(
                  index: 2,
                  selected: currentIndex == 2,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                ),
                navItem(
                  index: 3,
                  selected: currentIndex == 3,
                  icon: const Icon(Icons.send_outlined),
                ),
                navItem(
                  index: 4,
                  selected: currentIndex == 4,
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
