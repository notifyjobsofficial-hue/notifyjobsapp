import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_update_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../providers/content_providers.dart';

/// Updates Tab Screen: Admit Cards, Results, Answer Keys, Syllabus (Specification 53–57)
class UpdatesScreen extends ConsumerStatefulWidget {
  final String? initialTab;

  const UpdatesScreen({super.key, this.initialTab});

  @override
  ConsumerState<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    'All Updates',
    'Admit Cards',
    'Results',
    'Answer Keys',
    'Exam Dates',
    'Syllabus',
    'Govt Updates',
  ];

  @override
  void initState() {
    super.initState();
    int initIndex = 0;
    if (widget.initialTab != null) {
      final tab = widget.initialTab!.toLowerCase().replaceAll('-', '_');
      if (tab == 'all' || tab == 'all_updates') {
        initIndex = 0;
      } else if (tab == 'admit_cards' ||
          tab == 'admitcards' ||
          tab == 'admit_card' ||
          tab == 'admitcard') {
        initIndex = 1;
      } else if (tab == 'results' || tab == 'result') {
        initIndex = 2;
      } else if (tab == 'answer_keys' ||
          tab == 'answerkeys' ||
          tab == 'answer_key' ||
          tab == 'answerkey') {
        initIndex = 3;
      } else if (tab == 'exam_dates' ||
          tab == 'examdates' ||
          tab == 'exam_date' ||
          tab == 'examdate') {
        initIndex = 4;
      } else if (tab == 'syllabus') {
        initIndex = 5;
      } else if (tab == 'govt_updates' ||
          tab == 'govtupdates' ||
          tab == 'govt_update' ||
          tab == 'updates' ||
          tab == 'govt') {
        initIndex = 6;
      }
    }
    _tabController = TabController(
        length: _tabs.length, vsync: this, initialIndex: initIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allUpdates = ref.watch(allUpdatesProvider);
    final admitCards = ref.watch(admitCardsProvider);
    final results = ref.watch(resultsProvider);
    final answerKeys = ref.watch(answerKeysProvider);
    final examDates = ref.watch(examDatesProvider);
    final syllabus = ref.watch(syllabusProvider);
    final govtUpdates = ref.watch(govtUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Updates'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => HapticFeedback.selectionClick(),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.muted,
          labelStyle: AppTypography.button
              .copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.caption
              .copyWith(fontSize: 13, fontWeight: FontWeight.w500),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: isDark ? AppColors.darkBorder : AppColors.border,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTabContent(
            items: allUpdates,
            emptyTitle: 'No Updates Live',
            emptyMessage:
                'Admit cards, results, exam schedules, and government circulars will appear here as soon as published.',
            emptyIcon: Icons.campaign_outlined,
          ),
          _buildTabContent(
            items: admitCards,
            emptyTitle: 'No Admit Cards Live',
            emptyMessage:
                'New call letters and city intimation slips will appear here as soon as announced.',
            emptyIcon: Icons.badge_outlined,
          ),
          _buildTabContent(
            items: results,
            emptyTitle: 'No Results Declared',
            emptyMessage:
                'Merit lists, scorecard links, and cutoffs will appear here as soon as announced.',
            emptyIcon: Icons.emoji_events_outlined,
          ),
          _buildTabContent(
            items: answerKeys,
            emptyTitle: 'No Answer Keys Yet',
            emptyMessage:
                'Provisional answer keys and objection challenge windows will appear here.',
            emptyIcon: Icons.fact_check_outlined,
          ),
          _buildTabContent(
            items: examDates,
            emptyTitle: 'No Exam Dates Announced',
            emptyMessage:
                'Upcoming test schedules, session dates, and shift timings will appear here.',
            emptyIcon: Icons.calendar_month_outlined,
          ),
          _buildTabContent(
            items: syllabus,
            emptyTitle: 'No Syllabus Released',
            emptyMessage:
                'Updated examination schemes and topic-wise marks distribution will appear here.',
            emptyIcon: Icons.menu_book_outlined,
          ),
          _buildTabContent(
            items: govtUpdates,
            emptyTitle: 'No Government Updates',
            emptyMessage:
                'Official announcements, admissions, scholarships, and departmental circulars will appear here.',
            emptyIcon: Icons.notifications_none_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required List<dynamic> items,
    required String emptyTitle,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        ref.invalidate(firestoreContentStreamProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: AppColors.primary,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: NjEmptyState(
                    title: emptyTitle,
                    message: emptyMessage,
                    icon: emptyIcon,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return NjUpdateCard(
                  item: item,
                  onTap: () => context.push('/update/${item.id}'),
                );
              },
            ),
    );
  }
}
