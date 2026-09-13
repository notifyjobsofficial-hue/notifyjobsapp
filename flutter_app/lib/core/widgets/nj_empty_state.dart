import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_button.dart';

/// Clean Icon-Based Empty State Widget (Specification 98 & 129)
class NjEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NjEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTypography.sectionHeading.copyWith(
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              NjButton(
                label: actionLabel!,
                size: NjButtonSize.sm,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
