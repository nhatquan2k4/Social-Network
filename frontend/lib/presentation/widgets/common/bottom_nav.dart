import 'dart:ui';

import 'package:flutter/material.dart';

const bool _showBottomNavDebug = false;

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
            if (!isChatTab)
              Icon(
                icon,
                size: 34,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
            if (isChatTab)
              _LucideSendIcon(
                size: 29,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _LucideSendIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _LucideSendIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LucideSendPainter(color: color)),
    );
  }
}

class _LucideSendPainter extends CustomPainter {
  final Color color;

  const _LucideSendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2.0 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(14.536 * scaleX, 21.686 * scaleY)
      ..cubicTo(
        14.804 * scaleX,
        22.212 * scaleY,
        15.593 * scaleX,
        22.191 * scaleY,
        15.748 * scaleX,
        21.662 * scaleY,
      )
      ..lineTo(22.248 * scaleX, 2.662 * scaleY)
      ..cubicTo(
        22.412 * scaleX,
        2.182 * scaleY,
        21.951 * scaleX,
        1.721 * scaleY,
        21.471 * scaleX,
        1.885 * scaleY,
      )
      ..lineTo(2.471 * scaleX, 8.385 * scaleY)
      ..cubicTo(
        1.942 * scaleX,
        8.54 * scaleY,
        1.921 * scaleX,
        9.329 * scaleY,
        2.447 * scaleX,
        9.597 * scaleY,
      )
      ..lineTo(10.377 * scaleX, 12.777 * scaleY)
      ..cubicTo(
        10.856 * scaleX,
        12.97 * scaleY,
        11.297 * scaleX,
        13.41 * scaleY,
        11.488 * scaleX,
        13.889 * scaleY,
      )
      ..close();

    final tail = Path()
      ..moveTo(21.854 * scaleX, 2.147 * scaleY)
      ..lineTo(10.914 * scaleX, 13.086 * scaleY);

    canvas.drawPath(body, stroke);
    canvas.drawPath(tail, stroke);
  }

  @override
  bool shouldRepaint(covariant _LucideSendPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
