import 'package:flutter/material.dart';

class FeedSkeletonList extends StatelessWidget {
  const FeedSkeletonList({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => const PostCardSkeleton(),
    );
  }
}

class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({super.key});

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.45 + (_controller.value * 0.35);
        final baseColor = Colors.grey.withValues(alpha: opacity);

        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    _SkeletonBox(
                      width: 32,
                      height: 32,
                      radius: 16,
                      color: baseColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            width: 110,
                            height: 10,
                            radius: 6,
                            color: baseColor,
                          ),
                          const SizedBox(height: 6),
                          _SkeletonBox(
                            width: 70,
                            height: 8,
                            radius: 4,
                            color: baseColor,
                          ),
                        ],
                      ),
                    ),
                    _SkeletonBox(
                      width: 24,
                      height: 8,
                      radius: 4,
                      color: baseColor,
                    ),
                  ],
                ),
              ),
              _SkeletonBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width,
                radius: 0,
                color: baseColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _SkeletonBox(
                          width: 22,
                          height: 22,
                          radius: 11,
                          color: baseColor,
                        ),
                        const SizedBox(width: 10),
                        _SkeletonBox(
                          width: 22,
                          height: 22,
                          radius: 11,
                          color: baseColor,
                        ),
                        const SizedBox(width: 10),
                        _SkeletonBox(
                          width: 22,
                          height: 22,
                          radius: 11,
                          color: baseColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SkeletonBox(
                      width: 200,
                      height: 10,
                      radius: 6,
                      color: baseColor,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(
                      width: 160,
                      height: 10,
                      radius: 6,
                      color: baseColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
