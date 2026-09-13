import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_card.dart';
import 'nj_badge.dart';
import 'nj_status_badge.dart';
import '../../features/models/content_model.dart';

/// Native Job Card Component (Specification 23, 24, 25, 26, 129)
class NjJobCard extends StatelessWidget {
  final ContentModel job;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback? onToggleSave;
  final VoidCallback? onShare;

  const NjJobCard({
    super.key,
    required this.job,
    this.isSaved = false,
    required this.onTap,
    this.onToggleSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NjCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Badge & Dynamic Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: NjBadge(
                  label: job.categoryDisplay,
                  variant: job.isAndamanJob
                      ? (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.primary)
                      : (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.primary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NjStatusBadge(
                  applicationLastDate: job.applicationLastDate,
                  statusOverride: job.statusOverride,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Job Title (600–700, No word-by-word wrapping)
          Text(
            job.title,
            style: AppTypography.cardTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Organization / Department / Employer
          Row(
            children: [
              Icon(
                job.isPrivateJob
                    ? Icons.business_rounded
                    : Icons.account_balance_outlined,
                size: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  job.isPrivateJob
                      ? (job.companyName ?? job.organization)
                      : job.organization,
                  style: AppTypography.subtitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Compact Metadata Grid (Vacancies, Qualification, Last Date / Private specifics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
              ),
            ),
            child: job.isPrivateJob
                ? Row(
                    children: [
                      // Salary
                      Expanded(
                        child: _buildMetaItem(
                          label: 'Salary / Pay',
                          value: (job.salaryRange?.isNotEmpty ?? false)
                              ? job.salaryRange!
                              : (job.salary.isNotEmpty ? job.salary : 'Best in Industry'),
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      // Island / Location
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildMetaItem(
                            label: 'Island / Area',
                            value: (job.island?.isNotEmpty ?? false)
                                ? job.island!
                                : (job.location.isNotEmpty ? job.location : 'Andaman'),
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      // Type
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildMetaItem(
                            label: 'Employment',
                            value: job.employmentType ?? 'Full Time',
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Vacancies
                      Expanded(
                        child: _buildMetaItem(
                          label: 'Vacancies',
                          value: job.vacancies.isNotEmpty ? job.vacancies : '—',
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      // Qualification
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildMetaItem(
                            label: 'Qualification',
                            value: job.qualification.isNotEmpty
                                ? job.qualification
                                : '—',
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      // Last Date
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildMetaItem(
                            label: 'Last Date',
                            value: job.displayLastDate,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 14),

          // Bottom Action Row: Save, Share, View Details
          Row(
            children: [
              // Save / Bookmark Icon Button (Specification 25)
              _buildIconButton(
                icon: isSaved
                    ? const Icon(Icons.bookmark_rounded,
                        color: AppColors.primary, size: 20)
                    : Icon(
                        Icons.bookmark_border_rounded,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                        size: 20,
                      ),
                tooltip: isSaved ? 'Saved' : 'Save Job',
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (onToggleSave != null) onToggleSave!();
                },
                isDark: isDark,
              ),
              const SizedBox(width: 8),

              // Share Icon Button (Specification 26)
              _buildIconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
                  size: 20,
                ),
                tooltip: 'Share',
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (onShare != null) onShare!();
                },
                isDark: isDark,
              ),
              const Spacer(),

              // View Details Button
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: AppTypography.button.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Colors.white,
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

  Widget _buildMetaItem({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 12,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon,
        ),
      ),
    );
  }
}
