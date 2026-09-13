import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_update_card.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../providers/content_providers.dart';
import '../providers/categories_provider.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';

/// Premium Scrolling Home Screen (Specification 18, 19, 21, 22, 52, 101)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider);
    final popularJobs = ref.watch(popularThisWeekProvider);
    final andamanJobs = ref.watch(andamanJobsProvider);
    final results = ref.watch(resultsProvider);
    final admitCards = ref.watch(admitCardsProvider);
    final articles = ref.watch(articlesProvider);
    final savedJobsNotifier = ref.read(savedJobsProvider.notifier);
    final savedJobs = ref.watch(savedJobsProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await Future.delayed(const Duration(milliseconds: 600));
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. App Header (Specification 18)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & App Name
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'NJ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appSettings.appTitle,
                                style: AppTypography.majorHeading.copyWith(
                                  fontSize: 18,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.navy,
                                ),
                              ),
                              Text(
                                'Govt Jobs & Admit Cards',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Notification Bell Button
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy,
                              ),
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search Bar Trigger (Specification 21)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search jobs, exams, departments...',
                              style: AppTypography.body.copyWith(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Latest Alert Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.softGreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SSC CGL & A&N Police 2026 recruitments open now!',
                            style: AppTypography.caption.copyWith(
                              color:
                                  isDark ? Colors.white : AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Quick Categories (2 Columns, Compact Tiles) (Specification 22)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NjSectionHeader(
                        title: 'Quick Categories',
                        subtitle: 'Explore by department & qualification',
                        onViewAll: () => context.push('/jobs'),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: categories.take(8).length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 58,
                        ),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/jobs?category=${cat.slug}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: cat.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      cat.iconData,
                                      size: 18,
                                      color: cat.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: AppTypography.cardTitle.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.navy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 5. Popular This Week (Specification 86)
              if (popularJobs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NjSectionHeader(
                          title: 'Popular This Week',
                          subtitle: 'Top viewed vacancies by aspirants',
                          onViewAll: () => context.push('/jobs'),
                        ),
                        const SizedBox(height: 12),
                        ...popularJobs.take(2).map((job) {
                          final isSaved =
                              savedJobs.any((item) => item.id == job.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NjJobCard(
                              job: job,
                              isSaved: isSaved,
                              onTap: () => context.push('/job/${job.id}'),
                              onToggleSave: () async {
                                final saved =
                                    await savedJobsNotifier.toggleSave(job);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(saved
                                          ? 'Saved'
                                          : 'Removed from Saved Jobs'),
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
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],

              // 6. Dedicated Andaman & Nicobar Section (Specification 52)
              if (andamanJobs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NjSectionHeader(
                          title: 'Andaman & Nicobar Jobs',
                          subtitle: 'Recruitments across Port Blair & Islands',
                          onViewAll: () => context.push('/andaman'),
                        ),
                        const SizedBox(height: 12),
                        ...andamanJobs.take(2).map((job) {
                          final isSaved =
                              savedJobs.any((item) => item.id == job.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NjJobCard(
                              job: job,
                              isSaved: isSaved,
                              onTap: () => context.push('/job/${job.id}'),
                              onToggleSave: () async {
                                final saved =
                                    await savedJobsNotifier.toggleSave(job);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(saved
                                          ? 'Saved'
                                          : 'Removed from Saved Jobs'),
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
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],

              // 7. Latest Results & Admit Cards Grid
              if (results.isNotEmpty || admitCards.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NjSectionHeader(
                          title: 'Results & Admit Cards',
                          subtitle: 'Exam cutoffs, hall tickets & answer keys',
                          onViewAll: () => context.push('/updates'),
                        ),
                        const SizedBox(height: 12),
                        if (admitCards.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NjUpdateCard(
                              item: admitCards.first,
                              onTap: () => context
                                  .push('/update/${admitCards.first.id}'),
                            ),
                          ),
                        if (results.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NjUpdateCard(
                              item: results.first,
                              onTap: () =>
                                  context.push('/update/${results.first.id}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],

              // 8. Latest Articles / Preparation Guides
              if (articles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NjSectionHeader(
                          title: 'Latest Articles & Roadmaps',
                          subtitle: 'Preparation strategies from toppers',
                          onViewAll: () =>
                              context.push('/jobs?category=articles'),
                        ),
                        const SizedBox(height: 12),
                        ...articles.take(2).map((article) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NjUpdateCard(
                              item: article,
                              onTap: () =>
                                  context.push('/article/${article.id}'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
