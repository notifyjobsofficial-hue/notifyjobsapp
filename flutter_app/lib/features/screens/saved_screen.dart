import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';

/// Saved Jobs Screen (Specification 25, 100)
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedJobs = ref.watch(savedJobsProvider);
    final savedJobsNotifier = ref.read(savedJobsProvider.notifier);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Jobs (${savedJobs.length})',
          style: AppTypography.majorHeading.copyWith(
            fontSize: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
      ),
      body: savedJobs.isEmpty
          ? NjEmptyState(
              title: 'No Saved Jobs Yet',
              message:
                  'Bookmark jobs by tapping the bookmark icon to review and apply to them later, even without an internet connection.',
              icon: Icons.bookmark_border_rounded,
              actionLabel: 'Browse Jobs',
              onAction: () => context.go('/jobs'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: savedJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return NjJobCard(
                  job: job,
                  isSaved: true,
                  onTap: () => context.push('/job/${job.id}'),
                  onToggleSave: () async {
                    final saved = await savedJobsNotifier.toggleSave(job);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(saved ? 'Saved' : 'Removed from Saved Jobs'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onShare: () => NjShareSheet.show(
                    context,
                    content: job,
                    shareBaseUrl: appSettings.shareBaseUrl,
                  ),
                );
              },
            ),
    );
  }
}
