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
    'Admit Cards',
    'Results',
    'Answer Keys',
    'Syllabus',
  ];

  @override
  void initState() {
    super.initState();
    int initIndex = 0;
    if (widget.initialTab != null) {
      if (widget.initialTab == 'results') initIndex = 1;
      if (widget.initialTab == 'answer_keys') initIndex = 2;
      if (widget.initialTab == 'syllabus') initIndex = 3;
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
    final admitCards = ref.watch(admitCardsProvider);
    final results = ref.watch(resultsProvider);
    final answerKeys = ref.watch(answerKeysProvider);
    final syllabus = ref.watch(syllabusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Updates'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => HapticFeedback.selectionClick(),
          isScrollable: false,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.muted,
          labelStyle: AppTypography.button.copyWith(fontSize: 12),
          unselectedLabelStyle: AppTypography.caption.copyWith(fontSize: 12),
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: isDark ? AppColors.darkBorder : AppColors.border,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Admit Cards Tab
          admitCards.isEmpty
              ? const NjEmptyState(
                  title: 'No Admit Cards Live',
                  message:
                      'New call letters and city intimation slips will appear here as soon as announced.',
                  icon: Icons.badge_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: admitCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = admitCards[index];
                    return NjUpdateCard(
                      item: item,
                      onTap: () => context.push('/update/${item.id}'),
                    );
                  },
                ),

          // 2. Results Tab
          results.isEmpty
              ? const NjEmptyState(
                  title: 'No Results Declared',
                  message:
                      'Merit lists, scorecard links, and cutoffs will appear here as soon as announced.',
                  icon: Icons.emoji_events_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return NjUpdateCard(
                      item: item,
                      onTap: () => context.push('/update/${item.id}'),
                    );
                  },
                ),

          // 3. Answer Keys Tab
          answerKeys.isEmpty
              ? const NjEmptyState(
                  title: 'No Answer Keys Yet',
                  message:
                      'Provisional answer keys and objection challenge windows will appear here.',
                  icon: Icons.fact_check_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: answerKeys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = answerKeys[index];
                    return NjUpdateCard(
                      item: item,
                      onTap: () => context.push('/update/${item.id}'),
                    );
                  },
                ),

          // 4. Syllabus Tab
          syllabus.isEmpty
              ? const NjEmptyState(
                  title: 'No Syllabus Released',
                  message:
                      'Updated examination schemes and topic-wise marks distribution will appear here.',
                  icon: Icons.menu_book_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: syllabus.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = syllabus[index];
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
