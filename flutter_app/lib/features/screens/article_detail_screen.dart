import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_badge.dart';
import '../../core/widgets/nj_button.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final String id;

  const ArticleDetailScreen({super.key, required this.id});

  Future<void> _launchExternalUrl(
      BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Official link is not available yet.')),
      );
      return;
    }
    final uri = Uri.tryParse(urlString.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(contentByIdProvider(id));
    final isSaved = ref.watch(isSavedProvider(id));

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Details')),
        body: const NjEmptyState(
          title: 'Article Not Found',
          message: 'This post may have been removed or updated.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.organization.isNotEmpty ? item.organization : 'Notice Details',
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
                        ? 'Removed from saved items'
                        : 'Saved for offline access',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => NjShareSheet.show(context, content: item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NjBadge(
                        label: item.categoryDisplay,
                        variant: NjBadgeVariant.secondary,
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
                  if (item.advtNo != null && item.advtNo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ref No: ${item.advtNo}',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Dates
            if (item.importantDates.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Key Dates', icon: Icons.event_available_rounded),
              NjCard(
                child: Column(
                  children: item.importantDates.map((d) {
                    return _buildDateRow(d.label, d.date);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Content Body / Steps
            if (item.body.isNotEmpty) ...[
              const NjSectionHeader(
                  title: 'Instructions & Details',
                  icon: Icons.checklist_rounded),
              NjCard(
                child: Text(item.body, style: AppTypography.bodyMedium),
              ),
              const SizedBox(height: 20),
            ],

            // Important Links
            const NjSectionHeader(
                title: 'Direct Official Links', icon: Icons.link_rounded),
            NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.applyUrl != null && item.applyUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Access / Check Directly',
                      icon: Icons.open_in_browser_rounded,
                      onPressed: () =>
                          _launchExternalUrl(context, item.applyUrl),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (item.officialNotificationUrl != null &&
                      item.officialNotificationUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Download Official Notice',
                      icon: Icons.description_outlined,
                      variant: NjButtonVariant.secondary,
                      onPressed: () => _launchExternalUrl(
                          context, item.officialNotificationUrl),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (item.officialWebsiteUrl != null &&
                      item.officialWebsiteUrl!.isNotEmpty) ...[
                    NjButton(
                      label: 'Visit Official Website',
                      icon: Icons.language_rounded,
                      variant: NjButtonVariant.outline,
                      onPressed: () =>
                          _launchExternalUrl(context, item.officialWebsiteUrl),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Source Disclaimer
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
                        'Disclaimer',
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Information is sourced directly from the official portal of ${item.organization}. '
                    'Notify Jobs is an independent public awareness service.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  ref.read(savedJobsProvider.notifier).toggleSaved(item);
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => NjShareSheet.show(context, content: item),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NjButton(
                  label: 'Open Official Link',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => _launchExternalUrl(
                    context,
                    (item.applyUrl != null && item.applyUrl!.isNotEmpty)
                        ? item.applyUrl
                        : item.officialWebsiteUrl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }
}
