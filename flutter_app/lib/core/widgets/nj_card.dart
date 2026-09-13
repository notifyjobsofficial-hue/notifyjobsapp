import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Maths Yoddha-inspired Polished Surface Card (Specification 13, 24, 129)
class NjCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final bool hasPressEffect;

  const NjCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.color,
    this.borderColor,
    this.borderRadius = 18.0,
    this.hasPressEffect = true,
  });

  @override
  State<NjCard> createState() => _NjCardState();
}

class _NjCardState extends State<NjCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
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
    final surfaceColor = widget.color ??
        widget.backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.surface);
    final borderCol = widget.borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.border);

    Widget cardBody = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null || !widget.hasPressEffect) {
      return GestureDetector(
        onTap: widget.onTap,
        child: cardBody,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: (_) {
            HapticFeedback.selectionClick();
            _controller.forward();
          },
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: cardBody,
        ),
      ),
    );
  }
}
