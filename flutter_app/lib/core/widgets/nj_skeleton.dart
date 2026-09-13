import 'package:flutter/material.dart';

/// Shimmering Skeleton Loader Component (Specification 97 & 129)
class NjSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const NjSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  const NjSkeleton.card({
    super.key,
    this.width,
    this.height = 140.0,
    this.borderRadius = 18.0,
  });

  const NjSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 1000.0;

  @override
  State<NjSkeleton> createState() => _NjSkeletonState();
}

class _NjSkeletonState extends State<NjSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor.withOpacity(_animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
