import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_update_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';

/// Saved Screen with Dual Tabs: Saved Jobs & Saved Updates (Specification 25, 100)
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allSaved = ref.watch(savedJobsProvider);
    final savedNotifier = ref.read(savedJobsProvider.notifier);
    final appSettings = ref.watch(appSettingsProvider);

    final savedJobs = allSaved.where((item) => item.isJob).toList();
    final savedUpdates = allSaved.where((item) => !item.isJob).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Bookmarks',
          style: AppTypography.majorHeading.copyWith(
            fontSize: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => HapticFeedback.selectionClick(),
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.muted,
          labelStyle: AppTypography.button.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTypography.caption.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: isDark ? AppColors.darkBorder : AppColors.border,
          tabs: [
            Tab(text: 'Saved Jobs (${savedJobs.length})'),
            Tab(text: 'Saved Updates (${savedUpdates.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          // Tab 1: Saved Jobs
          savedJobs.isEmpty
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: savedJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = savedJobs[index];
                    return NjJobCard(
                      job: job,
                      isSaved: true,
                      onTap: () => context.push('/job/${job.id}'),
                      onToggleSave: () async {
                        final saved = await savedNotifier.toggleSave(job);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                saved ? 'Saved' : 'Removed from Saved Jobs',
                              ),
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

          // Tab 2: Saved Updates
          savedUpdates.isEmpty
              ? NjEmptyState(
                  title: 'No Saved Updates Yet',
                  message:
                      'Bookmark admit cards, results, exam schedules, and circulars to keep track of them offline.',
                  icon: Icons.notifications_none_rounded,
                  actionLabel: 'Browse Updates',
                  onAction: () => context.go('/updates'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: savedUpdates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = savedUpdates[index];
                    return NjUpdateCard(
                      item: item,
                      onTap: () => context.push('/update/${item.id}'),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
