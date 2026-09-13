import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import '../providers/content_providers.dart';
import '../providers/storage_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_update_card.dart';
import 'article_detail_screen.dart';
import 'job_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'all';
  List<String> _recentSearches = [];

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'All'},
    {'id': 'latest_jobs', 'label': 'Latest Jobs'},
    {'id': 'andaman_job', 'label': 'A&N Jobs'},
    {'id': 'private_job', 'label': 'Private Jobs'},
    {'id': 'admit_card', 'label': 'Admit Cards'},
    {'id': 'results', 'label': 'Results'},
    {'id': 'answer_key', 'label': 'Answer Keys'},
    {'id': 'admission', 'label': 'Admissions'},
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
    final queryText = _controller.text.trim();
    final results = ref.watch(searchContentProvider(queryText));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search jobs, department, admit card...',
            hintStyle: AppTypography.bodyMedium
                .copyWith(color: AppColors.textDisabled),
            border: InputBorder.none,
            isDense: true,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (val) => setState(() {}),
          onSubmitted: _onSearchSubmitted,
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
                    selectedColor: AppColors.primarySubtle,
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
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
                ? _buildRecentSearchesView()
                : _buildSearchResultsView(results),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesView() {
    if (_recentSearches.isEmpty) {
      return const NjEmptyState(
        icon: Icons.search_rounded,
        title: 'Search Opportunities',
        message: 'Type an exam name, department, or post to find updates.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Searches', style: AppTypography.titleSmall),
            TextButton(
              onPressed: _clearAllSearches,
              child: Text(
                'Clear All',
                style: AppTypography.captionMedium
                    .copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((query) {
            return InputChip(
              label: Text(query, style: AppTypography.bodySmall),
              deleteIcon: const Icon(Icons.close_rounded, size: 16),
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        if (item.contentType == 'government_job' ||
            item.contentType == 'latest_jobs' ||
            item.contentType == 'andaman_job' ||
            item.contentType == 'private_job') {
          return NjJobCard(
            job: item,
            onTap: () {
              _onSearchSubmitted(_controller.text.trim());
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailScreen(id: item.id)),
              );
            },
          );
        } else {
          return NjUpdateCard(
            item: item,
            onTap: () {
              _onSearchSubmitted(_controller.text.trim());
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(id: item.id)),
              );
            },
          );
        }
      },
    );
  }
}
