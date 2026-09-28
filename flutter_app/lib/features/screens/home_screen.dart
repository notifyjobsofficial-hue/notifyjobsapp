import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_update_card.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../../core/widgets/nj_skeleton.dart';
import '../../core/widgets/nj_section_error.dart';
import '../../core/widgets/nj_icon_container.dart';
import '../models/content_model.dart';
import '../models/category_model.dart';
import '../providers/content_providers.dart';
import '../providers/categories_provider.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/notification_providers.dart';

/// Remodeled Home Screen (Clean content hierarchy, no artificial ticker, information-dense)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            ref.invalidate(homeLatestJobsStreamProvider);
            ref.invalidate(homeClosingSoonStreamProvider);
            ref.invalidate(homePopularJobsStreamProvider);
            ref.invalidate(homeAndamanJobsStreamProvider);
            ref.invalidate(homeAdmitCardsStreamProvider);
            ref.invalidate(homeResultsStreamProvider);
            ref.invalidate(homeArticlesStreamProvider);
            ref.invalidate(firestoreContentStreamProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.royalBlue,
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. App Header (Renders instantly on Frame 1)
              SliverToBoxAdapter(child: _HomeHeader()),

              // 2. Prominent Rounded Search Trigger
              SliverToBoxAdapter(child: _HomeSearchBar()),

              // 3. Urgent Updates (Only appears when items are actually urgent, zero space if none)
              SliverToBoxAdapter(child: _HomeUrgentSection()),

              // 4. Today's Updates (Real counts: New Jobs, Admit Cards, Results, Closing Soon)
              SliverToBoxAdapter(child: _HomeTodaysUpdatesSection()),

              // 5. Quick Categories (Compact 4x2 Grid: 8 core categories)
              SliverToBoxAdapter(child: _HomeQuickCategoriesSection()),

              // 6. Closing Soon (Imminent application deadlines)
              SliverToBoxAdapter(child: _HomeClosingSoonSection()),

              // 7. Andaman & Nicobar Jobs (Dedicated distinct island section)
              SliverToBoxAdapter(child: _HomeAndamanSection()),

              // 8. Latest Government Jobs (Compact information-dense cards)
              SliverToBoxAdapter(child: _HomeLatestJobsSection()),

              // 9. Latest Exam Updates (Admit Cards, Results, Answer Keys, Exam Dates)
              SliverToBoxAdapter(child: _HomeExamUpdatesSection()),

              // 10. Community CTA (WhatsApp & Telegram channels)
              SliverToBoxAdapter(child: _HomeCommunityCtaSection()),

              // 11. Official / Legal Disclaimer footer
              SliverToBoxAdapter(child: _HomeLegalDisclaimer()),

              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

/// 1. App Header Component (Compact, Logo, Dynamic Greeting, Notification bell)
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appTitle = ref.watch(appSettingsProvider.select((s) => s.appTitle));
    final hasUnread = ref.watch(notificationHasUnreadProvider);

    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/branding/notify_jobs_logo_compact.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appTitle.isNotEmpty ? appTitle : 'Notify Jobs',
                    style: AppTypography.majorHeading.copyWith(
                      fontSize: 18,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                  ),
                  Text(
                    greeting,
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: Material(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/notifications');
                },
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color:
                            isDark ? AppColors.darkTextPrimary : AppColors.navy,
                      ),
                      if (hasUnread)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurfaceElevated
                                    : const Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Prominent Rounded Search Bar Trigger
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.royalBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search jobs, department, admit card...',
                  style: AppTypography.bodySmall.copyWith(
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.muted,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3. Urgent Updates (Only renders when items are genuinely urgent; zero space if empty)
class _HomeUrgentSection extends ConsumerWidget {
  const _HomeUrgentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgentItems = ref.watch(urgentContentProvider);
    if (urgentItems.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF7F1D1D).withOpacity(0.25)
              : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'URGENT UPDATES',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deadlines & Immediate Releases',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFF991B1B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...urgentItems.take(2).map((item) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (item.isJob) {
                    context.push('/job/${item.id}');
                  } else {
                    context.push('/update/${item.id}');
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 8,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF7F1D1D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.displayLastDate,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFFDC2626),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 4. Today's Updates (Real data summary card: New Jobs, Admit Cards, Results, Closing Soon)
class _HomeTodaysUpdatesSection extends ConsumerWidget {
  const _HomeTodaysUpdatesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaysUpdatesSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Updates',
                      style: AppTypography.sectionHeading.copyWith(
                        fontSize: 15,
                        color:
                            isDark ? AppColors.darkTextPrimary : AppColors.navy,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/updates'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.royalBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatPill(
                  count: summary.newJobs,
                  label: 'New Jobs',
                  icon: Icons.work_outline_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () => context.go('/jobs'),
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  count: summary.admitCards,
                  label: 'Admit Cards',
                  icon: Icons.badge_outlined,
                  color: AppColors.purple,
                  isDark: isDark,
                  onTap: () => context.push('/updates?tab=admit_cards'),
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  count: summary.results,
                  label: 'Results',
                  icon: Icons.emoji_events_outlined,
                  color: const Color(0xFFEA580C),
                  isDark: isDark,
                  onTap: () => context.push('/updates?tab=results'),
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  count: summary.closingSoon,
                  label: 'Closing Soon',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFFDC2626),
                  isDark: isDark,
                  onTap: () => context.go('/jobs?filter=closing_soon'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: AppTypography.majorHeading.copyWith(
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 6. Quick Categories Section (Dynamic via categoriesProvider & homeQuickCategoriesProvider)
class _HomeQuickCategoriesSection extends ConsumerWidget {
  const _HomeQuickCategoriesSection();

  static IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'work':
      case 'business_center':
        return Icons.work_outline_rounded;
      case 'location_on':
      case 'place':
      case 'landscape':
        return Icons.landscape_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'train':
      case 'directions_railway':
        return Icons.directions_railway_rounded;
      case 'payments':
      case 'currency_rupee':
        return Icons.payments_rounded;
      case 'security':
      case 'shield':
        return Icons.shield_rounded;
      case 'badge':
        return Icons.badge_outlined;
      case 'emoji_events':
        return Icons.emoji_events_outlined;
      case 'fact_check':
        return Icons.fact_check_outlined;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'article':
        return Icons.article_outlined;
      default:
        return Icons.category_rounded;
    }
  }

  static Color _parseColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveCategories = ref.watch(homeQuickCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<CategoryModel> categories = liveCategories.isNotEmpty
        ? liveCategories
        : defaultFallbackCategories.where((c) => c.showOnHome).take(8).toList();

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Categories',
                  style: AppTypography.sectionHeading.copyWith(
                    fontSize: 15,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/jobs'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.royalBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                mainAxisExtent: 68,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final color = _parseColor(cat.colorHex, AppColors.royalBlue);
                final icon = _getIconData(cat.icon);
                final label =
                    (cat.shortName != null && cat.shortName!.isNotEmpty)
                        ? cat.shortName!
                        : cat.name;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final dest =
                        (cat.destination != null && cat.destination!.isNotEmpty)
                            ? cat.destination!
                            : '/jobs?category=${cat.slug}';
                    context.push(dest);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark
                              ? color.withOpacity(0.18)
                              : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 6. Closing Soon Section (Compact horizontal scroll for imminent deadlines)
class _HomeClosingSoonSection extends ConsumerWidget {
  const _HomeClosingSoonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final closingSoonAsync = ref.watch(homeClosingSoonStreamProvider);

    return closingSoonAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (jobs) {
        if (jobs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NjSectionHeader(
                  title: 'Closing Soon',
                  subtitle: 'Imminent application deadlines',
                  onViewAll: () => context.push('/jobs?filter=closing_soon'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: jobs.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildClosingSoonCard(context, job, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClosingSoonCard(
      BuildContext context, ContentModel job, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/job/${job.id}');
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? const Color(0xFF7F1D1D).withOpacity(0.5)
                : const Color(0xFFFCA5A5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.organization.isNotEmpty ? job.organization : 'Govt Job',
                    style: TextStyle(
                      fontSize: 10.5,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 10, color: Color(0xFFDC2626)),
                      const SizedBox(width: 3),
                      Text(
                        job.displayLastDate,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              job.title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.displayVacancies.isNotEmpty
                      ? '${job.displayVacancies} posts'
                      : 'Official Notice',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.primary,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 14, color: Color(0xFFDC2626)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. Dedicated Andaman & Nicobar Section
class _HomeAndamanSection extends ConsumerWidget {
  const _HomeAndamanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final andamanAsync = ref.watch(homeAndamanJobsStreamProvider);

    return andamanAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (jobs) {
        if (jobs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF0F6FE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.secondary.withOpacity(0.25)
                    : const Color(0xFFBFDBFE),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const NjCategoryIcon(
                          variant: NjIconVariant.andamanJobs,
                          size: 36,
                          iconSize: 18,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Andaman & Nicobar Jobs',
                              style: AppTypography.sectionHeading.copyWith(
                                fontSize: 14.5,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy,
                              ),
                            ),
                            Text(
                              'Port Blair & Islands Recruitments',
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/andaman'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: AppTypography.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.royalBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...jobs.take(2).map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HomeJobCardItem(job: job),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 9. Latest Government Jobs Section
class _HomeLatestJobsSection extends ConsumerWidget {
  const _HomeLatestJobsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    if (!settings.latestJobsEnabled) return const SizedBox.shrink();

    final latestAsync = ref.watch(homeLatestJobsStreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NjSectionHeader(
            title: settings.latestJobsTitle.isNotEmpty
                ? settings.latestJobsTitle
                : 'Latest Government Jobs',
            subtitle: settings.latestJobsSubtitle,
            onViewAll: () => context.push('/jobs'),
          ),
          const SizedBox(height: 10),
          latestAsync.when(
            loading: () => const Column(
              children: [
                NjJobCardSkeleton(),
                SizedBox(height: 10),
                NjJobCardSkeleton(),
              ],
            ),
            error: (err, _) => NjSectionError(
              message: 'Could not load latest jobs',
              onRetry: () => ref.invalidate(homeLatestJobsStreamProvider),
            ),
            data: (jobs) {
              if (jobs.isEmpty) return const SizedBox.shrink();

              return Column(
                children: jobs.take(settings.latestJobsMaxItems).map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HomeJobCardItem(job: job),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 10. Latest Exam Updates Section (Admit Cards, Results, Answer Keys)
class _HomeExamUpdatesSection extends ConsumerWidget {
  const _HomeExamUpdatesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admitAsync = ref.watch(homeAdmitCardsStreamProvider);
    final resultAsync = ref.watch(homeResultsStreamProvider);

    final isLoading = admitAsync.isLoading || resultAsync.isLoading;
    final admitCards = admitAsync.value ?? [];
    final results = resultAsync.value ?? [];

    if (!isLoading && admitCards.isEmpty && results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NjSectionHeader(
            title: 'Exam Updates & Releases',
            subtitle: 'Admit cards, results & scorecards',
            onViewAll: () => context.push('/updates'),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Column(
              children: [
                NjUpdateCardSkeleton(),
                SizedBox(height: 10),
                NjUpdateCardSkeleton(),
              ],
            )
          else ...[
            if (admitCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NjUpdateCard(
                  item: admitCards.first,
                  onTap: () => context.push('/update/${admitCards.first.id}'),
                ),
              ),
            if (results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NjUpdateCard(
                  item: results.first,
                  onTap: () => context.push('/update/${results.first.id}'),
                ),
              ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Dedicated Job Card Item with Isolated Save State
class _HomeJobCardItem extends ConsumerWidget {
  final ContentModel job;

  const _HomeJobCardItem({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isSavedProvider(job.id));
    final shareBaseUrl =
        ref.watch(appSettingsProvider.select((s) => s.shareBaseUrl));

    return NjJobCard(
      job: job,
      isSaved: isSaved,
      onTap: () => context.push('/job/${job.id}'),
      onToggleSave: () async {
        final saved =
            await ref.read(savedJobsProvider.notifier).toggleSave(job);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(saved ? 'Saved' : 'Removed from Saved Jobs'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onShare: () => NjShareSheet.show(
        context,
        content: job,
        shareBaseUrl: shareBaseUrl,
      ),
    );
  }
}

/// 12. Community CTA Section (WhatsApp & Telegram Channels from Admin Settings)
class _HomeCommunityCtaSection extends ConsumerWidget {
  const _HomeCommunityCtaSection();

  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final hasWhatsApp = settings.whatsappUrl.isNotEmpty;
    final hasTelegram = settings.telegramUrl.isNotEmpty;

    if (!hasWhatsApp && !hasTelegram) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (hasWhatsApp)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _launchUrl(settings.whatsappUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF25D366).withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_rounded,
                              color: Color(0xFF25D366),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WhatsApp',
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.navy,
                                  ),
                                ),
                                Text(
                                  'Instant alerts',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (hasWhatsApp && hasTelegram) const SizedBox(width: 10),
              if (hasTelegram)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _launchUrl(settings.telegramUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF229ED9).withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF229ED9).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF229ED9),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Telegram',
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.navy,
                                  ),
                                ),
                                Text(
                                  'Official channel',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
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
}

/// 11. Official / Legal Disclaimer footer
class _HomeLegalDisclaimer extends StatelessWidget {
  const _HomeLegalDisclaimer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Center(
        child: Text(
          'Notify Jobs is an independent exam & recruitment notification service. All official notices & logos are property of their respective government bodies.',
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary.withOpacity(0.6)
                : AppColors.muted,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
