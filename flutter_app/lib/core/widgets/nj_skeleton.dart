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

/// Compact Live Updates Ticker Skeleton matching NjVerticalLiveTicker (74px)
class NjLiveTickerSkeleton extends StatelessWidget {
  const NjLiveTickerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(15)),
            ),
            child: const Center(
              child: NjSkeleton(width: 36, height: 16, borderRadius: 4),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NjSkeleton(width: 110, height: 12, borderRadius: 4),
                SizedBox(height: 8),
                NjSkeleton(width: double.infinity, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Compact Category Grid Skeleton (4 tiles, 2 columns, height 58)
class NjQuickCategoriesSkeleton extends StatelessWidget {
  final int count;

  const NjQuickCategoriesSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 58,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: const Row(
            children: [
              NjSkeleton(width: 34, height: 34, borderRadius: 10),
              SizedBox(width: 8),
              Expanded(
                child: NjSkeleton(height: 14, borderRadius: 4),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact Job Card Skeleton matching NjJobCard
class NjJobCardSkeleton extends StatelessWidget {
  const NjJobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badges
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NjSkeleton(width: 90, height: 22, borderRadius: 6),
              NjSkeleton(width: 70, height: 22, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),
          // Title lines
          const NjSkeleton(height: 16, borderRadius: 4),
          const SizedBox(height: 6),
          const NjSkeleton(width: 200, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          // Org
          const NjSkeleton(width: 140, height: 12, borderRadius: 4),
          const SizedBox(height: 14),
          // Meta strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(child: NjSkeleton(height: 24, borderRadius: 4)),
                SizedBox(width: 12),
                Expanded(child: NjSkeleton(height: 24, borderRadius: 4)),
                SizedBox(width: 12),
                Expanded(child: NjSkeleton(height: 24, borderRadius: 4)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Bottom action row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  NjSkeleton(width: 34, height: 34, borderRadius: 10),
                  SizedBox(width: 8),
                  NjSkeleton(width: 34, height: 34, borderRadius: 10),
                ],
              ),
              NjSkeleton(width: 110, height: 34, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact Update Card Skeleton matching NjUpdateCard
class NjUpdateCardSkeleton extends StatelessWidget {
  const NjUpdateCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NjSkeleton(width: 130, height: 14, borderRadius: 4),
              NjSkeleton(width: 75, height: 20, borderRadius: 6),
            ],
          ),
          SizedBox(height: 10),
          NjSkeleton(height: 16, borderRadius: 4),
          SizedBox(height: 6),
          NjSkeleton(width: 180, height: 16, borderRadius: 4),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NjSkeleton(width: 110, height: 12, borderRadius: 4),
              NjSkeleton(width: 100, height: 28, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
