import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_card.dart';
import 'nj_badge.dart';
import 'nj_new_badge.dart';
import 'nj_status_badge.dart';
import '../../features/models/content_model.dart';

/// Native Compact Job Card Component (Information-dense, reduced vertical height, zero blank space)
class NjJobCard extends StatelessWidget {
  final ContentModel job;
  final bool isSaved;
  final int newBadgeDurationDays;
  final VoidCallback onTap;
  final VoidCallback? onToggleSave;
  final VoidCallback? onShare;

  const NjJobCard({
    super.key,
    required this.job,
    this.isSaved = false,
    this.newBadgeDurationDays = 3,
    required this.onTap,
    this.onToggleSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final orgName = job.isPrivateJob
        ? (job.companyName ?? job.organization)
        : job.organization;
    final displayOrg = orgName.isNotEmpty ? orgName : 'Govt Organization';
    final initial =
        displayOrg.trim().isNotEmpty ? displayOrg.trim()[0].toUpperCase() : 'G';

    return NjCard(
      onTap: onTap,
      borderRadius: 14,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Row: Category/Job Type Badge, subtle NEW pill, and Dynamic Status Badge
          Row(
            children: [
              Flexible(
                child: NjBadge(
                  label: job.jobTypeName ?? job.categoryDisplay,
                  variant: job.isAndamanJob
                      ? (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.blue)
                      : (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.primary),
                ),
              ),
              if (job.isNew(newBadgeDurationDays)) ...[
                const SizedBox(width: 6),
                const NjNewBadge(),
              ],
              const Spacer(),
              Flexible(
                child: NjStatusBadge(
                  contentType: job.contentType,
                  applicationLastDate: job.applicationLastDate,
                  statusOverride: job.statusOverride,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),

          // 2. Organization Avatar & Title Block
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: job.isPrivateJob
                      ? const Color(0xFFF3E8FF)
                      : (isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.softBlueSurface),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: job.isPrivateJob
                        ? const Color(0xFFD8B4FE)
                        : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFBFDBFE)),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color:
                        job.isPrivateJob ? AppColors.purple : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayOrg,
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
                    const SizedBox(height: 2),
                    Text(
                      job.title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13.5,
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
          const SizedBox(height: 9),

          // 3. Compact Information-Dense Metadata Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
                width: 0.8,
              ),
            ),
            child: job.isPrivateJob
                ? Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          label: 'Salary',
                          value: (job.salaryRange?.isNotEmpty ?? false)
                              ? job.salaryRange!
                              : (job.salary.isNotEmpty
                                  ? job.salary
                                  : 'Best in Industry'),
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _buildMetaItem(
                            label: 'Island / Area',
                            value: (job.island?.isNotEmpty ?? false)
                                ? job.island!
                                : (job.location.isNotEmpty
                                    ? job.location
                                    : 'Andaman'),
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _buildMetaItem(
                            label: 'Last Date',
                            value: job.displayLastDate,
                            isDark: isDark,
                            isHighlight: true,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          label: 'Vacancies',
                          value: job.displayVacancies,
                          isDark: isDark,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _buildMetaItem(
                            label: 'Qualification',
                            value: job.qualification.isNotEmpty
                                ? job.qualification
                                : 'Check Notice',
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _buildMetaItem(
                            label: 'Last Date',
                            value: job.displayLastDate,
                            isDark: isDark,
                            isHighlight: true,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),

          // 4. Location, Views & Time Row
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  job.location.isNotEmpty ? job.location : 'All India',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (job.views > 0) ...[
                Icon(
                  Icons.visibility_outlined,
                  size: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
                ),
                const SizedBox(width: 3),
                Text(
                  '${job.views}',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                job.relativePublishedDate,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5. Bottom Action Row: Bookmark, Share, View Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleSave != null)
                    _buildActionButton(
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 18,
                        color: isSaved
                            ? AppColors.royalBlue
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.muted),
                      ),
                      tooltip: isSaved ? 'Saved' : 'Save Job',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onToggleSave!();
                      },
                      isDark: isDark,
                    ),
                  if (onToggleSave != null && onShare != null)
                    const SizedBox(width: 6),
                  if (onShare != null)
                    _buildActionButton(
                      icon: Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                      ),
                      tooltip: 'Share',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onShare!();
                      },
                      isDark: isDark,
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.royalBlue.withOpacity(0.18)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.royalBlue.withOpacity(0.35)
                            : const Color(0xFFBFDBFE),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF93C5FD)
                                  : AppColors.royalBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : AppColors.royalBlue,
                        ),
                      ],
                    ),
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
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 9.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 11.5,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight
                ? const Color(0xFFDC2626)
                : (isDark ? AppColors.darkTextPrimary : AppColors.navy),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
      ),
    );
  }
}
