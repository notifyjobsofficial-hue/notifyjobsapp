import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Section Header with Responsive "View All" (Specification 20 & 129)
class NjSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final VoidCallback? onViewAll;
  final String viewAllLabel;

  const NjSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onViewAll,
    this.viewAllLabel = 'View All',
  });

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon as IconData, size: 20, color: AppColors.primary);
    } else if (icon is Widget) {
      iconWidget = icon as Widget;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Prevent squishing on very narrow viewports (< 340px)
        final isVeryNarrow = constraints.maxWidth < 340;

        Widget headerTitle = Row(
          children: [
            if (iconWidget != null) ...[
              iconWidget,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.sectionHeading.copyWith(
                      fontSize: isVeryNarrow ? 16 : 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

        Widget? viewAllButton = onViewAll != null
            ? GestureDetector(
                onTap: onViewAll,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewAllLabel,
                        style: AppTypography.button.copyWith(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              )
            : null;

        if (viewAllButton == null) {
          return headerTitle;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: headerTitle),
            const SizedBox(width: 8),
            viewAllButton,
          ],
        );
      },
    );
  }
}
