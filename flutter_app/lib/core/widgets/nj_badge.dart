import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum NjBadgeVariant { primary, secondary, softGreen, blue, amber, error, slate, purple }

/// Pill Badge Component for Categories, Departments, and Tags (Specification 129)
class NjBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final NjBadgeVariant variant;
  final Color? customColor;
  final Color? customBgColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const NjBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = NjBadgeVariant.slate,
    this.customColor,
    this.customBgColor,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;

    if (customColor != null) {
      textColor = customColor!;
      bgColor = customBgColor ?? customColor!.withOpacity(0.12);
      borderColor = customColor!.withOpacity(0.25);
    } else {
      switch (variant) {
        case NjBadgeVariant.primary:
          textColor = AppColors.primaryDark;
          bgColor = AppColors.softGreen;
          borderColor = AppColors.primary.withOpacity(0.25);
          break;
        case NjBadgeVariant.secondary:
          textColor = AppColors.navy;
          bgColor = const Color(0xFFF1F5F9);
          borderColor = AppColors.border;
          break;
        case NjBadgeVariant.softGreen:
          textColor = const Color(0xFF0D9488);
          bgColor = const Color(0xFFF0FDFA);
          borderColor = const Color(0xFF99F6E4);
          break;
        case NjBadgeVariant.blue:
          textColor = AppColors.blue;
          bgColor = AppColors.blueSoft;
          borderColor = const Color(0xFFBFDBFE);
          break;
        case NjBadgeVariant.amber:
          textColor = const Color(0xFFB45309);
          bgColor = AppColors.amberSoft;
          borderColor = const Color(0xFFFDE68A);
          break;
        case NjBadgeVariant.error:
          textColor = AppColors.error;
          bgColor = AppColors.errorSoft;
          borderColor = const Color(0xFFFECACA);
          break;
        case NjBadgeVariant.purple:
          textColor = AppColors.purple;
          bgColor = AppColors.purpleSoft;
          borderColor = const Color(0xFFDDD6FE);
          break;
        case NjBadgeVariant.slate:
          textColor = AppColors.secondaryText;
          bgColor = const Color(0xFFF1F5F9);
          borderColor = AppColors.border;
          break;
      }
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
