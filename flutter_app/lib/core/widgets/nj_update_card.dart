import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_card.dart';
import 'nj_badge.dart';
import 'nj_icon_container.dart';
import '../../features/models/content_model.dart';

/// Specialized Compact Update Card for Results, Admit Cards, Answer Keys, Syllabus
class NjUpdateCard extends StatelessWidget {
  final ContentModel item;
  final VoidCallback onTap;
  final VoidCallback? onShare;
  final int newBadgeDurationDays;

  const NjUpdateCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onShare,
    this.newBadgeDurationDays = 3,
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
        dateLabel = 'Objection Till';
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
        actionLabel = 'Check Update';
        actionIcon = Icons.article_outlined;
        accentColor = AppColors.primary;
        dateLabel = 'Published';
        dateValue = item.displayPublishedDate;
        break;
    }

    return NjCard(
      onTap: onTap,
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row with Category Icon, Org & Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NjCategoryIcon(
                categorySlug: item.contentType,
                size: 36,
                iconSize: 18,
                borderRadius: 9,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.organization.isNotEmpty
                                ? item.organization
                                : 'Official Update',
                            style: AppTypography.subtitle.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (item.isNew(newBadgeDurationDays)) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: NjBadge(
                            label: item.categoryDisplay,
                            customColor: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.darkTextPrimary : AppColors.navy,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Date Strip & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$dateLabel: ',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.muted,
                              ),
                            ),
                            TextSpan(
                              text: dateValue,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon, size: 12, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
