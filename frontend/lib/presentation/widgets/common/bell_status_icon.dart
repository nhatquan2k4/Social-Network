import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BellStatusIcon extends StatelessWidget {
  final bool isMuted;
  final double size;
  final Color color;

  const BellStatusIcon({
    super.key,
    required this.isMuted,
    this.size = 24,
    this.color = const Color(0xFF1D1D21),
  });

  @override
  Widget build(BuildContext context) {
    if (!isMuted) {
      return Icon(Icons.notifications_none, size: size, color: color);
    }

    return SvgPicture.string(
      _bellOffSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

const String _bellOffSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10.268 21a2 2 0 0 0 3.464 0"/>
  <path d="M17 17H4a1 1 0 0 1-.74-1.673C4.59 13.956 6 12.499 6 8a6 6 0 0 1 .258-1.742"/>
  <path d="m2 2 20 20"/>
  <path d="M8.668 3.01A6 6 0 0 1 18 8c0 2.687.77 4.653 1.707 6.05"/>
</svg>
''';
