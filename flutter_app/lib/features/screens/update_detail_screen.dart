import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_badge.dart';
import '../../core/widgets/nj_button.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_markdown_view.dart';
import '../../core/widgets/nj_official_source_sheet.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../../core/utils/normalization_utils.dart';

/// Specialized Detail Screen for Exam Updates:
/// Admit Cards, Results, Answer Keys, and Syllabus (Specification 53–57)
class UpdateDetailScreen extends ConsumerWidget {
  final String id;

  const UpdateDetailScreen({super.key, required this.id});

  Future<void> _launchExternalUrl(
      BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Official link is not available yet.')),
      );
      return;
    }
    String cleanedUrl = urlString.trim();
    if (!cleanedUrl.startsWith('http://') &&
        !cleanedUrl.startsWith('https://') &&
        !cleanedUrl.startsWith('tel:') &&
        !cleanedUrl.startsWith('mailto:')) {
      cleanedUrl = 'https://$cleanedUrl';
    }
    final uri = Uri.tryParse(cleanedUrl);
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open external link.')),
      );
    }
  }

  void _openOfficialSource(
    BuildContext context,
    WidgetRef ref,
    String? urlString,
    OfficialSourceType type,
  ) {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Official link is not available yet.')),
      );
      return;
    }
    final appSettings = ref.read(appSettingsProvider);
    NjOfficialSourceSheet.show(
      context,
      url: urlString,
      type: type,
      appSettings: appSettings,
      onProceed: () => _launchExternalUrl(context, urlString),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = ref.watch(contentByIdProvider(id));
    final isSaved = ref.watch(isSavedProvider(id));
    final appSettings = ref.watch(appSettingsProvider);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Update')),
        body: const NjEmptyState(
          title: 'Update Not Found',
          message: 'This notice may have been removed or updated.',
        ),
      );
    }

    // Type-specific badge and CTA configurations
    String typeHeading;
    String primaryCtaLabel;
    IconData primaryCtaIcon;
    Color accentColor;
    String statusTitle;
    String statusSubtitle;

    switch (item.contentType) {
      case 'admit_card':
        typeHeading = 'Admit Card / Hall Ticket';
        primaryCtaLabel = 'Download Admit Card';
        primaryCtaIcon = Icons.badge_outlined;
        accentColor = AppColors.purple;
        statusTitle = 'Admit Card Available';
        statusSubtitle = 'Official hall ticket and venue details are live';
        break;
      case 'result':
        typeHeading = 'Exam Result / Merit List';
        primaryCtaLabel = 'View Official Result';
        primaryCtaIcon = Icons.emoji_events_outlined;
        accentColor = const Color(0xFFEA580C);
        statusTitle = 'Result Declared';
        statusSubtitle =
            'Merit list and scorecards published by official board';
        break;
      case 'answer_key':
        typeHeading = 'Answer Key & Challenge';
        primaryCtaLabel = 'View Answer Key';
        primaryCtaIcon = Icons.fact_check_outlined;
        accentColor = const Color(0xFF0284C7);
        statusTitle = 'Answer Key Released';
        statusSubtitle = 'Provisional key open for candidate verification';
        break;
      case 'exam_date':
        typeHeading = 'Exam Date & Schedule';
        primaryCtaLabel = 'View Exam Schedule';
        primaryCtaIcon = Icons.calendar_month_rounded;
        accentColor = const Color(0xFF0D9488);
        statusTitle = 'Exam Date Announced';
        statusSubtitle = 'Official exam schedule and shift timings are live';
        break;
      case 'syllabus':
        typeHeading = 'Exam Pattern & Syllabus';
        primaryCtaLabel = 'Download Syllabus';
        primaryCtaIcon = Icons.menu_book_outlined;
        accentColor = const Color(0xFF475569);
        statusTitle = 'Syllabus Available';
        statusSubtitle = 'Updated examination scheme and section-wise syllabus';
        break;
      case 'govt_update':
      case 'admission':
      case 'scholarship':
        typeHeading = 'Government Update';
        primaryCtaLabel = 'View Official Announcement';
        primaryCtaIcon = Icons.campaign_rounded;
        accentColor = const Color(0xFF4F46E5);
        statusTitle = 'Official Announcement';
        statusSubtitle =
            'Notice published by respective department or ministry';
        break;
      default:
        typeHeading = 'Exam Notice';
        primaryCtaLabel = 'Check Official Link';
        primaryCtaIcon = Icons.open_in_new_rounded;
        accentColor = AppColors.primary;
        statusTitle = 'Official Notice';
        statusSubtitle = 'Verified announcement from recruitment board';
        break;
    }

    final effectiveLink = (item.applyUrl?.isNotEmpty == true)
        ? item.applyUrl!
        : (item.officialNotificationUrl?.isNotEmpty == true)
            ? item.officialNotificationUrl!
            : item.officialWebsiteUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.organization.isNotEmpty ? item.organization : typeHeading,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isSaved ? AppColors.primary : null,
            ),
            tooltip: isSaved ? 'Remove from Saved' : 'Save Update',
            onPressed: () {
              ref.read(savedJobsProvider.notifier).toggleSaved(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Removed from saved updates'
                        : 'Update saved for offline access',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => NjShareSheet.show(
              context,
              content: item,
              shareBaseUrl: appSettings.shareBaseUrl,
            ),
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
                        label: typeHeading,
                        customColor: accentColor,
                      ),
                      const Spacer(),
                      Text(
                        item.displayPublishedDate,
                        style: AppTypography.captionMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.title, style: AppTypography.headingSmall),
                  if (item.organization.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.organization,
                      style: AppTypography.titleSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if (item.department != null &&
                      item.department!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.department!,
                      style: AppTypography.captionMedium
                          .copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Real Status Highlight
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(primaryCtaIcon, size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusTitle,
                                style: AppTypography.labelLarge.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                statusSubtitle,
                                style: AppTypography.captionMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (item.views > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          '${item.views} views',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Schedule & Important Dates
            if (item.importantDates.isNotEmpty) ...[
              const NjSectionHeader(
                title: 'Schedule & Key Dates',
                icon: Icons.event_available_rounded,
              ),
              NjCard(
                child: Column(
                  children: item.importantDates.map((d) {
                    final formattedDate = NormalizationUtils.formatDate(d.date);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              d.label,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              d.isTentative
                                  ? '$formattedDate (Tentative)'
                                  : formattedDate,
                              textAlign: TextAlign.end,
                              style: AppTypography.titleSmall,
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

            // 3. Exam Pattern (If available for Syllabus/Admit Card)
            if (item.examPattern.isNotEmpty) ...[
              const NjSectionHeader(
                title: 'Examination Pattern',
                icon: Icons.table_chart_outlined,
              ),
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
                  rows: item.examPattern.map((p) {
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

            // 4. Instructions & Content Details (Markdown / Plaintext)
            if (item.body.isNotEmpty || item.excerpt.isNotEmpty) ...[
              const NjSectionHeader(
                title: 'Instructions & Overview',
                icon: Icons.description_outlined,
              ),
              NjCard(
                child: NjMarkdownView(
                  data: item.body.isNotEmpty ? item.body : item.excerpt,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 5. Official Direct Links Card
            const NjSectionHeader(
              title: 'Direct Official Portals',
              icon: Icons.link_rounded,
            ),
            NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.applyUrl != null && item.applyUrl!.isNotEmpty) ...[
                    NjButton(
                      label: primaryCtaLabel,
                      icon: primaryCtaIcon,
                      onPressed: () => _openOfficialSource(
                        context,
                        ref,
                        item.applyUrl,
                        OfficialSourceType.apply,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (item.officialNotificationUrl != null &&
                      item.officialNotificationUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Download Official PDF Notice',
                      icon: Icons.download_rounded,
                      variant: NjButtonVariant.secondary,
                      onPressed: () => _openOfficialSource(
                        context,
                        ref,
                        item.officialNotificationUrl,
                        OfficialSourceType.notification,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (item.officialWebsiteUrl != null &&
                      item.officialWebsiteUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Visit Official Board Website',
                      icon: Icons.language_rounded,
                      variant: NjButtonVariant.outline,
                      onPressed: () => _openOfficialSource(
                        context,
                        ref,
                        item.officialWebsiteUrl,
                        OfficialSourceType.website,
                      ),
                    ),
                  ],
                  // Extra Custom Links from Firestore
                  ...item.importantLinks.where((link) {
                    return link.url.isNotEmpty &&
                        link.url != item.applyUrl &&
                        link.url != item.officialNotificationUrl &&
                        link.url != item.officialWebsiteUrl;
                  }).map((link) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: NjButton(
                        label: link.title.isNotEmpty ? link.title : 'Open Link',
                        icon: Icons.link_rounded,
                        variant: NjButtonVariant.outline,
                        onPressed: () => _launchExternalUrl(context, link.url),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. Disclaimer
            NjCard(
              color:
                  isDark ? AppColors.darkSurfaceElevated : AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Verified Source Disclaimer',
                        style: AppTypography.titleSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Information is curated from the official portal of ${item.organization.isNotEmpty ? item.organization : "the respective authority"}. '
                    'Notify Jobs is an independent public notification service and is not affiliated with any government recruitment board.',
                    style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Bar with Action CTA
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.8,
            ),
          ),
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
                  ref.read(savedJobsProvider.notifier).toggleSaved(item);
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => NjShareSheet.show(
                  context,
                  content: item,
                  shareBaseUrl: appSettings.shareBaseUrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NjButton(
                  label: primaryCtaLabel,
                  icon: primaryCtaIcon,
                  onPressed: () {
                    final type = effectiveLink == item.officialNotificationUrl
                        ? OfficialSourceType.notification
                        : effectiveLink == item.officialWebsiteUrl
                            ? OfficialSourceType.website
                            : OfficialSourceType.apply;
                    _openOfficialSource(context, ref, effectiveLink, type);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
