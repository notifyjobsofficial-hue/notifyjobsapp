import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/content_model.dart';
import '../providers/content_providers.dart';
import '../providers/storage_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_update_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'all';
  List<String> _recentSearches = [];

  static const List<String> _popularQueries = [
    'SSC',
    'Railway',
    'Andaman Police',
    '10th Pass',
    '12th Pass',
    'Graduate',
    'Admit Card',
    'Result',
  ];

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'All'},
    {'id': 'government_job', 'label': 'Govt Jobs'},
    {'id': 'andaman_job', 'label': 'A&N Jobs'},
    {'id': 'private_job', 'label': 'Private Jobs'},
    {'id': 'admit_card', 'label': 'Admit Cards'},
    {'id': 'result', 'label': 'Results'},
    {'id': 'answer_key', 'label': 'Answer Keys'},
    {'id': 'syllabus', 'label': 'Syllabus'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    final storage = ref.read(storageServiceProvider);
    setState(() {
      _recentSearches = storage.getRecentSearches();
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    final storage = ref.read(storageServiceProvider);
    storage.addRecentSearch(query.trim());
    _loadRecentSearches();
  }

  void _removeSearch(String query) {
    final storage = ref.read(storageServiceProvider);
    storage.removeRecentSearch(query);
    _loadRecentSearches();
  }

  void _clearAllSearches() {
    final storage = ref.read(storageServiceProvider);
    storage.clearRecentSearches();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final queryText = _controller.text.trim();
    final results = ref.watch(searchContentProvider(queryText));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search jobs, admit cards, results...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => setState(() {}),
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    selectedColor: isDark
                        ? AppColors.royalBlue.withOpacity(0.25)
                        : const Color(0xFFEFF6FF),
                    checkmarkColor: AppColors.royalBlue,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.royalBlue
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondaryText),
                    ),
                    backgroundColor:
                        isDark ? AppColors.darkSurface : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.royalBlue
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Content Area
          Expanded(
            child: queryText.isEmpty
                ? _buildRecentAndPopularSearches(isDark)
                : _buildSearchResultsView(results),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAndPopularSearches(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Popular Searches Section
        Row(
          children: [
            const Icon(Icons.trending_up_rounded,
                size: 17, color: AppColors.royalBlue),
            const SizedBox(width: 6),
            Text(
              'Popular Searches',
              style: AppTypography.titleSmall.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularQueries.map((query) {
            return ActionChip(
              label: Text(query),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
              backgroundColor: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                _controller.text = query;
                setState(() {});
                _onSearchSubmitted(query);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Recent Searches Section
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 17, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    'Recent Searches',
                    style: AppTypography.titleSmall.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _clearAllSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((query) {
              return InputChip(
                label: Text(query),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
                backgroundColor:
                    isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                deleteIcon: const Icon(Icons.close_rounded, size: 15),
                onDeleted: () => _removeSearch(query),
                onPressed: () {
                  _controller.text = query;
                  setState(() {});
                  _onSearchSubmitted(query);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResultsView(List<ContentModel> results) {
    var filtered = results;
    if (_selectedCategory != 'all') {
      filtered = results
          .where((item) =>
              item.contentType == _selectedCategory ||
              item.categoryIds.contains(_selectedCategory))
          .toList();
    }

    if (filtered.isEmpty) {
      return NjEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Matching Results',
        message:
            'We couldn\'t find any post matching "${_controller.text.trim()}". Try different keywords or filters.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filtered[index];
        if (item.isJob) {
          return NjJobCard(
            job: item,
            onTap: () {
              _onSearchSubmitted(_controller.text.trim());
              context.push('/job/${item.id}');
            },
          );
        } else {
          return NjUpdateCard(
            item: item,
            onTap: () {
              _onSearchSubmitted(_controller.text.trim());
              context.push('/update/${item.id}');
            },
          );
        }
      },
    );
  }
}
