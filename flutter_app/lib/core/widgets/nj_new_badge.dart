import 'package:flutter/material.dart';

/// Premium Subtle Pulsing Attention "NEW" Badge
///
/// Implements a gentle, non-jarring breath/glow pulse (1.4s cycle).
/// Strictly preserves high-contrast legibility of the white 'NEW' text on crimson red.
/// Pauses automatically when inactive via framework ticker lifecycle.
class NjNewBadge extends StatefulWidget {
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const NjNewBadge({
    super.key,
    this.fontSize = 8.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    this.borderRadius,
  });

  @override
  State<NjNewBadge> createState() => _NjNewBadgeState();
}

class _NjNewBadgeState extends State<NjNewBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _opacityAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.borderRadius ?? BorderRadius.circular(4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _opacityAnimation.value;
        final glow = _glowAnimation.value;

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(opacity),
            borderRadius: r,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(glow),
                blurRadius: 5.0 * opacity,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: Text(
            'NEW',
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        );
      },
    );
  }
}
