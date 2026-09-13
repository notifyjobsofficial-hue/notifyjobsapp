import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_card.dart';
import 'nj_badge.dart';
import '../../features/models/content_model.dart';

/// Specialized Update Card for Results, Admit Cards, Answer Keys, Syllabus (Specification 53–57)
class NjUpdateCard extends StatelessWidget {
  final ContentModel item;
  final VoidCallback onTap;
  final VoidCallback? onShare;

  const NjUpdateCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String actionLabel;
    IconData actionIcon;
    Color accentColor;
    String dateLabel;
    String dateValue;

    switch (item.contentType) {
      case 'result':
        actionLabel = 'View Result';
        actionIcon = Icons.emoji_events_outlined;
        accentColor = const Color(0xFFEA580C);
        dateLabel = 'Published';
        dateValue = item.displayPublishedDate;
        break;
      case 'admit_card':
        actionLabel = 'View Admit Card';
        actionIcon = Icons.badge_outlined;
        accentColor = AppColors.purple;
        dateLabel = 'Exam Date';
        dateValue = item.importantDates.isNotEmpty
            ? item.importantDates.first.date
            : 'Check Notice';
        break;
      case 'answer_key':
        actionLabel = 'View Answer Key';
        actionIcon = Icons.fact_check_outlined;
        accentColor = const Color(0xFF0284C7);
        dateLabel = 'Objection Last Date';
        dateValue = item.displayLastDate;
        break;
      case 'syllabus':
        actionLabel = 'View Syllabus';
        actionIcon = Icons.menu_book_outlined;
        accentColor = AppColors.secondaryText;
        dateLabel = 'Updated';
        dateValue = item.displayPublishedDate;
        break;
      default:
        actionLabel = 'Read Article';
        actionIcon = Icons.article_outlined;
        accentColor = AppColors.primary;
        dateLabel = 'Published';
        dateValue = item.displayPublishedDate;
        break;
    }

    return NjCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Organization & Category Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.organization.isNotEmpty
                      ? item.organization
                      : 'Notify Jobs Update',
                  style: AppTypography.subtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              NjBadge(
                label: item.categoryDisplay,
                customColor: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: AppTypography.cardTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Date Strip & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$dateLabel: ',
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.muted,
                    ),
                  ),
                  Text(
                    dateValue,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: accentColor.withOpacity(0.3), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon, size: 14, color: accentColor),
                      const SizedBox(width: 5),
                      Text(
                        actionLabel,
                        style: AppTypography.button.copyWith(
                          fontSize: 12,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
