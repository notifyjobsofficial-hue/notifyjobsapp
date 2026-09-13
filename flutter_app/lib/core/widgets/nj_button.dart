import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum NjButtonVariant { primary, secondary, outline, danger, ghost }

enum NjButtonSize { sm, md, lg }

/// Reusable Button with Micro-Press Scale Animation and Haptics (Specification 24, 105, 129)
class NjButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final NjButtonVariant variant;
  final NjButtonSize size;
  final dynamic icon;
  final bool isLoading;
  final bool isFullWidth;

  const NjButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NjButtonVariant.primary,
    this.size = NjButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<NjButton> createState() => _NjButtonState();
}

class _NjButtonState extends State<NjButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.selectionClick();
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case NjButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case NjButtonVariant.secondary:
        bgColor = AppColors.navy;
        textColor = Colors.white;
        break;
      case NjButtonVariant.outline:
        bgColor = Colors.white;
        textColor = AppColors.navy;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
      case NjButtonVariant.danger:
        bgColor = AppColors.error;
        textColor = Colors.white;
        break;
      case NjButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.secondaryText;
        break;
    }

    if (!isEnabled) {
      bgColor = bgColor.withOpacity(0.4);
      textColor = textColor.withOpacity(0.5);
    }

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (widget.size) {
      case NjButtonSize.sm:
        height = 36;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case NjButtonSize.md:
        height = 46;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 18);
        break;
      case NjButtonSize.lg:
        height = 54;
        fontSize = 15;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
    }

    Widget? iconWidget;
    if (widget.icon is IconData) {
      iconWidget =
          Icon(widget.icon as IconData, size: fontSize + 4, color: textColor);
    } else if (widget.icon is Widget) {
      iconWidget = widget.icon as Widget;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: fontSize + 2,
            height: fontSize + 2,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (iconWidget != null) ...[
          iconWidget,
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: AppTypography.button.copyWith(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: isEnabled ? widget.onPressed : null,
          child: Container(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: borderSide != BorderSide.none
                  ? Border.fromBorderSide(borderSide)
                  : null,
              boxShadow: widget.variant == NjButtonVariant.primary && isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
