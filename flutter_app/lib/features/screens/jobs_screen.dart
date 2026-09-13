import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../../core/widgets/nj_button.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';
import '../../core/widgets/nj_status_badge.dart';

/// Jobs Tab Screen with Filter Chips and Filter Bottom Sheet (Specification 50 & 51)
class JobsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const JobsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  late String _selectedChip;
  String _andamanSubFilter = 'All';

  // Filter bottom sheet state
  String _selectedQualification = 'All';
  String _selectedLocation = 'All';
  String _selectedStatus = 'All';

  final List<String> _chips = [
    'Latest',
    'All India',
    'Andaman',
    'SSC',
    'Railway',
    'Banking',
    'Police',
    'Defence',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      if (widget.initialCategory == 'andaman-nicobar') {
        _selectedChip = 'Andaman';
      } else if (widget.initialCategory == 'ssc') {
        _selectedChip = 'SSC';
      } else if (widget.initialCategory == 'railway') {
        _selectedChip = 'Railway';
      } else if (widget.initialCategory == 'banking') {
        _selectedChip = 'Banking';
      } else if (widget.initialCategory == 'police-defence') {
        _selectedChip = 'Police';
      } else {
        _selectedChip = 'Latest';
      }
    } else {
      _selectedChip = 'Latest';
    }
  }

  void _openFilterBottomSheet() {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Opportunities',
                          style: AppTypography.sectionHeading.copyWith(
                            fontSize: 17,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              _selectedQualification = 'All';
                              _selectedLocation = 'All';
                              _selectedStatus = 'All';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Qualification Filter
                    Text(
                      'Minimum Qualification',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        '10th Pass',
                        '12th Pass',
                        'Graduate',
                        'Post Graduate'
                      ].map((q) {
                        final isSel = _selectedQualification == q;
                        return ChoiceChip(
                          label: Text(q),
                          selected: isSel,
                          onSelected: (_) {
                            setSheetState(() => _selectedQualification = q);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Status Filter
                    Text(
                      'Application Status',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Open', 'Closing Soon'].map((s) {
                        final isSel = _selectedStatus == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSel,
                          onSelected: (_) {
                            setSheetState(() => _selectedStatus = s);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Buttons (Reset / Apply)
                    Row(
                      children: [
                        Expanded(
                          child: NjButton(
                            label: 'Apply Filters',
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allContent = ref.watch(allContentProvider);
    final savedJobsNotifier = ref.read(savedJobsProvider.notifier);
    final savedJobs = ref.watch(savedJobsProvider);
    final appSettings = ref.watch(appSettingsProvider);

    // Filter jobs
    final filteredJobs = allContent.where((item) {
      if (item.contentType != 'government_job' &&
          item.contentType != 'private_job' &&
          item.contentType != 'andaman_job') {
        return false;
      }

      // Chip Filter
      if (_selectedChip == 'Andaman') {
        if (!item.isAndamanJob) return false;
        if (_andamanSubFilter == 'Govt' && !item.isGovernmentJob) return false;
        if (_andamanSubFilter == 'Private' && !item.isPrivateJob) return false;
      } else if (_selectedChip == 'SSC') {
        if (!item.categoryIds.contains('ssc')) return false;
      } else if (_selectedChip == 'Railway') {
        if (!item.categoryIds.contains('railway')) return false;
      } else if (_selectedChip == 'Banking') {
        if (!item.categoryIds.contains('banking')) return false;
      } else if (_selectedChip == 'Police') {
        if (!item.categoryIds.contains('police-defence')) return false;
      } else if (_selectedChip == 'Defence') {
        if (!item.categoryIds.contains('police-defence')) return false;
      }

      // Qualification Filter
      if (_selectedQualification != 'All') {
        if (!item.qualification
            .toLowerCase()
            .contains(_selectedQualification.toLowerCase())) {
          return false;
        }
      }

      // Location Filter
      if (_selectedLocation != 'All') {
        if (!item.location
            .toLowerCase()
            .contains(_selectedLocation.toLowerCase())) {
          return false;
        }
      }

      // Status Filter
      if (_selectedStatus != 'All') {
        final statusInfo = NjStatusBadge.computeStatus(
          applicationLastDate: item.applicationLastDate,
          statusOverride: item.statusOverride,
        );
        if (_selectedStatus == 'Open' && statusInfo.label != 'Open') {
          return false;
        }
        if (_selectedStatus == 'Closing Soon' &&
            !statusInfo.label.contains('Closing')) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Government Jobs',
                    style: AppTypography.majorHeading.copyWith(
                      fontSize: 20,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                  ),
                  GestureDetector(
                    onTap: _openFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Filters',
                            style: AppTypography.button.copyWith(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips (Specification 50)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = _chips[index];
                  final isSelected = _selectedChip == chip;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedChip = chip);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurfaceElevated
                                : Colors.white),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chip,
                          style: AppTypography.button.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.secondaryText),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Secondary Andaman Sub-filter (Govt vs Private)
            if (_selectedChip == 'Andaman')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    _buildSubFilterChip('All A&N Jobs', 'All', isDark),
                    const SizedBox(width: 8),
                    _buildSubFilterChip('Government', 'Govt', isDark),
                    const SizedBox(width: 8),
                    _buildSubFilterChip('Private Jobs', 'Private', isDark),
                  ],
                ),
              ),

            // Filter Active Indicators
            if (_selectedQualification != 'All' || _selectedStatus != 'All')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Filtered by: ',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    if (_selectedQualification != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(_selectedQualification),
                          onDeleted: () =>
                              setState(() => _selectedQualification = 'All'),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    if (_selectedStatus != 'All')
                      Chip(
                        label: Text(_selectedStatus),
                        onDeleted: () =>
                            setState(() => _selectedStatus = 'All'),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),

            // Job List
            Expanded(
              child: filteredJobs.isEmpty
                  ? NjEmptyState(
                      title: 'No Jobs Found',
                      message:
                          'Try resetting your filters or selecting a different category.',
                      icon: Icons.search_off_rounded,
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        setState(() {
                          _selectedChip = 'Latest';
                          _selectedQualification = 'All';
                          _selectedLocation = 'All';
                          _selectedStatus = 'All';
                        });
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        final isSaved =
                            savedJobs.any((item) => item.id == job.id);

                        return NjJobCard(
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubFilterChip(String label, String value, bool isDark) {
    final isSelected = _andamanSubFilter == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _andamanSubFilter = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'Private' ? const Color(0xFF6366F1) : AppColors.primary)
              : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}
