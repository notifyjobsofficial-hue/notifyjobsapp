import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_model.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_badge.dart';
import '../../core/widgets/nj_button.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_info_tile.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_reward_sheet.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../../core/widgets/nj_status_badge.dart';

class JobDetailScreen extends ConsumerWidget {
  final String id;

  const JobDetailScreen({super.key, required this.id});

  Future<void> _launchExternalUrl(
      BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link is not available yet.')),
      );
      return;
    }
    final uri = Uri.tryParse(urlString.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  void _handleOfficialNotification(BuildContext context, ContentModel job) {
    final pdfUrl = job.officialNotificationUrl;
    if (pdfUrl == null || pdfUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification PDF link not available.')),
      );
      return;
    }

    NjRewardSheet.show(
      context,
      title: 'Download Official Notification',
      onRewardUnlocked: () => _launchExternalUrl(context, pdfUrl),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(contentByIdProvider(id));
    final isSaved = ref.watch(isSavedProvider(id));

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const NjEmptyState(
          title: 'Job Not Found',
          message: 'This post may have been removed or updated.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          job.organization.isNotEmpty ? job.organization : 'Job Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isSaved ? AppColors.primary : null,
            ),
            tooltip: isSaved ? 'Remove from Saved' : 'Save Job',
            onPressed: () {
              ref.read(savedJobsProvider.notifier).toggleSaved(job);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Removed from saved jobs'
                        : 'Job saved for offline access',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => NjShareSheet.show(context, content: job),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card
            NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NjBadge(
                        label: job.categoryDisplay,
                        variant: NjBadgeVariant.primary,
                      ),
                      const Spacer(),
                      NjStatusBadge(lastDate: job.lastDateParsed),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(job.title, style: AppTypography.headingSmall),
                  const SizedBox(height: 6),
                  Text(
                    job.organization,
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (job.department != null && job.department!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      job.department!,
                      style: AppTypography.captionMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                  if (job.advtNo != null && job.advtNo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Advt / Ref: ${job.advtNo}',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Verified Official Notification',
                        style: AppTypography.captionMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Overview 2x2 Grid
            Row(
              children: [
                Expanded(
                  child: NjInfoTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Total Vacancies',
                    value: job.vacancies.isNotEmpty
                        ? job.vacancies
                        : 'Not Specified',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NjInfoTile(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Salary / Pay',
                    value: job.salary.isNotEmpty ? job.salary : 'As per rules',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NjInfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Last Date',
                    value: job.displayLastDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NjInfoTile(
                    icon: Icons.location_on_outlined,
                    title: 'Job Location',
                    value: job.location.isNotEmpty ? job.location : 'All India',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Important Dates
            if (job.importantDates.isNotEmpty ||
                job.applicationStartDate != null) ...[
              const NjSectionHeader(
                  title: 'Important Dates', icon: Icons.event_note_rounded),
              NjCard(
                child: Column(
                  children: [
                    if (job.applicationStartDate != null &&
                        job.applicationStartDate!.isNotEmpty)
                      _buildDateRow(
                          'Application Starts', job.applicationStartDate!),
                    if (job.applicationLastDate != null &&
                        job.applicationLastDate!.isNotEmpty)
                      _buildDateRow('Last Date to Apply', job.displayLastDate,
                          isHighlight: true),
                    ...job.importantDates.map((d) {
                      return _buildDateRow(
                        d.label,
                        d.isTentative ? '${d.date} (Tentative)' : d.date,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Vacancy Breakdown
            if (job.vacanciesBreakdown.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Vacancy Breakdown', icon: Icons.view_list_rounded),
              NjCard(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppColors.primarySubtle),
                    columns: const [
                      DataColumn(
                          label: Text('Post Name',
                              style: AppTypography.labelLarge)),
                      DataColumn(
                          label: Text('Category',
                              style: AppTypography.labelLarge)),
                      DataColumn(
                          label: Text('Vacancies',
                              style: AppTypography.labelLarge)),
                      DataColumn(
                          label: Text('Pay Level',
                              style: AppTypography.labelLarge)),
                    ],
                    rows: job.vacanciesBreakdown.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(
                            item.postName.isNotEmpty ? item.postName : '-')),
                        DataCell(Text(
                            item.category.isNotEmpty ? item.category : '-')),
                        DataCell(
                            Text(item.count.isNotEmpty ? item.count : '-')),
                        DataCell(Text(item.payLevel ?? '-')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 5. Qualification / Eligibility
            if (job.qualification.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Eligibility & Qualification',
                  icon: Icons.school_outlined),
              NjCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.check_circle_outline,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(job.qualification,
                          style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 6. Age Limit
            if (job.ageLimits.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Age Limit', icon: Icons.hourglass_bottom_rounded),
              NjCard(
                child: Column(
                  children: job.ageLimits.map((limit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              limit.category.isNotEmpty
                                  ? limit.category
                                  : 'General',
                              style: AppTypography.bodyMedium),
                          Text(
                            '${limit.minAge} - ${limit.maxAge ?? 30} Years',
                            style: AppTypography.titleSmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 7. Application Fee
            if (job.applicationFees.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Application Fees', icon: Icons.payments_outlined),
              NjCard(
                child: Column(
                  children: job.applicationFees.map((fee) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fee.category, style: AppTypography.bodyMedium),
                          Text(
                            fee.amount > 0 ? '₹${fee.amount}' : '₹0 (Nil)',
                            style: AppTypography.titleSmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 8. Selection Process
            if (job.selectionProcess.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Selection Process', icon: Icons.fact_check_outlined),
              NjCard(
                child: Column(
                  children: job.selectionProcess.map((step) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primarySubtle,
                            child: Text(
                              '${step.stageNumber}',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step.name,
                                    style: AppTypography.titleSmall),
                                if (step.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    step.description,
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 9. Exam Pattern
            if (job.examPattern.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Exam Pattern', icon: Icons.description_outlined),
              NjCard(
                padding: EdgeInsets.zero,
                child: DataTable(
                  columns: const [
                    DataColumn(
                        label:
                            Text('Subject', style: AppTypography.labelLarge)),
                    DataColumn(
                        label: Text('Qs', style: AppTypography.labelLarge)),
                    DataColumn(
                        label: Text('Marks', style: AppTypography.labelLarge)),
                  ],
                  rows: job.examPattern.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.subject)),
                      DataCell(Text(p.questions)),
                      DataCell(Text(p.marks)),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 10. FAQs / Details
            if (job.faqs.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Frequently Asked Questions',
                  icon: Icons.quiz_outlined),
              ...job.faqs.map((faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NjCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 12),
                        title:
                            Text(faq.question, style: AppTypography.titleSmall),
                        children: [
                          Text(faq.answer,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],

            // 11. Important Official Links
            const NjSectionHeader(
                title: 'Important Official Links', icon: Icons.link_rounded),
            NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Direct Apply Online
                  if (job.applyUrl != null && job.applyUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Apply Online (Direct Link)',
                      icon: Icons.open_in_browser_rounded,
                      onPressed: () =>
                          _launchExternalUrl(context, job.applyUrl),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Rewarded PDF Notification
                  if (job.officialNotificationUrl != null &&
                      job.officialNotificationUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Download Official Notification (PDF)',
                      icon: Icons.download_rounded,
                      variant: NjButtonVariant.secondary,
                      onPressed: () =>
                          _handleOfficialNotification(context, job),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Direct Official Website
                  if (job.officialWebsiteUrl != null &&
                      job.officialWebsiteUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Visit Official Website',
                      icon: Icons.language_rounded,
                      variant: NjButtonVariant.outline,
                      onPressed: () =>
                          _launchExternalUrl(context, job.officialWebsiteUrl),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 12. Disclaimer
            NjCard(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Official Source Disclaimer',
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Information is curated from the official advertisement published by ${job.organization}. '
                    'Notify Jobs is an independent service and is not affiliated with any government recruitment body. '
                    'Candidates are advised to cross-verify all eligibility and deadlines on the official website.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 13. Related Opportunities
            Consumer(
              builder: (context, ref, child) {
                final relatedList = ref.watch(
                  categoryContentProvider(CategoryContentParams(
                      category: job.contentType, limit: 3)),
                );
                final filtered = relatedList
                    .where((item) => item.id != job.id)
                    .take(2)
                    .toList();
                if (filtered.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NjSectionHeader(
                        title: 'Related Opportunities',
                        icon: Icons.work_outline_rounded),
                    ...filtered.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NjJobCard(
                            job: item,
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(id: item.id)),
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      // 14. Sticky Bottom Action Dock
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton.filledTonal(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.textPrimary,
                ),
                onPressed: () {
                  ref.read(savedJobsProvider.notifier).toggleSaved(job);
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => NjShareSheet.show(context, content: job),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NjButton(
                  label: 'Apply Online',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => _launchExternalUrl(
                    context,
                    job.applyUrl ?? job.officialWebsiteUrl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isHighlight
                ? AppTypography.labelLarge.copyWith(color: AppColors.error)
                : AppTypography.bodyMedium,
          ),
          Text(
            value,
            style: isHighlight
                ? AppTypography.titleSmall.copyWith(color: AppColors.error)
                : AppTypography.titleSmall,
          ),
        ],
      ),
    );
  }
}
