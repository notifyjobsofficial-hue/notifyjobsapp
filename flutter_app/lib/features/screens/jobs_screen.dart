import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/categories_provider.dart';
import '../../core/widgets/nj_status_badge.dart';

/// Jobs Tab Screen with Filter Chips and Filter Bottom Sheet (Specification 50 & 51)
class JobsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialQualification;
  final String? initialFilter;

  const JobsScreen({
    super.key,
    this.initialCategory,
    this.initialQualification,
    this.initialFilter,
  });

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  late String _selectedChip;
  String _andamanSubFilter = 'All';

  // Search in jobs
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter bottom sheet state
  String _selectedQualification = 'All';
  String _selectedLocation = 'All';
  String _selectedJobType = 'All';
  String _selectedStatus = 'All';

  int get activeFilterCount {
    int count = 0;
    if (_selectedQualification != 'All') count++;
    if (_selectedLocation != 'All') count++;
    if (_selectedJobType != 'All') count++;
    if (_selectedStatus != 'All') count++;
    return count;
  }

  final List<String> _chips = [
    'Latest',
    'A&N',
    'All India',
    'Closing Soon',
  ];

  @override
  void initState() {
    super.initState();
    _applyInitialParameters();
  }

  @override
  void didUpdateWidget(covariant JobsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory ||
        widget.initialQualification != oldWidget.initialQualification ||
        widget.initialFilter != oldWidget.initialFilter) {
      _applyInitialParameters();
    }
  }

  void _applyInitialParameters() {
    if (widget.initialFilter == 'closing_soon') {
      _selectedChip = 'Closing Soon';
    } else if (widget.initialCategory != null &&
        widget.initialCategory!.isNotEmpty) {
      final cat = widget.initialCategory!.toLowerCase();
      if (cat.contains('andaman') || cat == 'a&n') {
        _selectedChip = 'A&N';
      } else if (cat == 'ssc') {
        _selectedChip = 'SSC';
      } else if (cat == 'railway') {
        _selectedChip = 'Railway';
      } else if (cat == 'banking') {
        _selectedChip = 'Banking';
      } else if (cat.contains('police') || cat == 'police-defence') {
        _selectedChip = 'Police';
      } else if (cat.contains('defence')) {
        _selectedChip = 'Defence';
      } else if (cat == 'all-india' || cat == 'all india') {
        _selectedChip = 'All India';
      } else if (cat == 'closing_soon' || cat == 'closing-soon') {
        _selectedChip = 'Closing Soon';
      } else if (cat == 'latest-jobs' || cat == 'latest') {
        _selectedChip = 'Latest';
      } else {
        // Support dynamic custom categories
        final formatted = widget.initialCategory!
            .replaceAll('-', ' ')
            .split(' ')
            .map((w) =>
                w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
        if (!_chips.contains(formatted)) {
          _chips.add(formatted);
        }
        _selectedChip = formatted;
      }
    } else {
      _selectedChip = 'Latest';
    }

    if (widget.initialQualification != null &&
        widget.initialQualification!.isNotEmpty) {
      final q = widget.initialQualification!.toLowerCase();
      if (q.contains('10')) {
        _selectedQualification = '10th Pass';
      } else if (q.contains('12')) {
        _selectedQualification = '12th Pass';
      } else if (q.contains('iti')) {
        _selectedQualification = 'ITI';
      } else if (q.contains('dip')) {
        _selectedQualification = 'Diploma';
      } else if (q.contains('post') || q.contains('pg')) {
        _selectedQualification = 'Post Graduate';
      } else if (q.contains('grad') || q.contains('degree')) {
        _selectedQualification = 'Graduate';
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allContent = ref.read(allContentProvider);

    // Temporary copy of sheet state for Cancel/Apply
    String tempQual = _selectedQualification;
    String tempLoc = _selectedLocation;
    String tempJobType = _selectedJobType;
    String tempStatus = _selectedStatus;
    String tempChip = _selectedChip;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Compute real-time live count
            final count = allContent.where((item) {
              if (item.contentType != 'government_job' &&
                  item.contentType != 'private_job' &&
                  item.contentType != 'andaman_job') {
                return false;
              }

              // Chip Category
              if (tempChip == 'Andaman' || tempChip == 'A&N') {
                if (!item.isAndamanJob) {
                  return false;
                }
              } else if (tempChip == 'SSC') {
                if (!item.isCategoryMatch('ssc')) {
                  return false;
                }
              } else if (tempChip == 'Railway') {
                if (!item.isCategoryMatch('railway')) {
                  return false;
                }
              } else if (tempChip == 'Banking') {
                if (!item.isCategoryMatch('banking')) {
                  return false;
                }
              } else if (tempChip == 'Police') {
                if (!item.isCategoryMatch('police') &&
                    !item.isCategoryMatch('police-defence')) {
                  return false;
                }
              } else if (tempChip == 'Defence') {
                if (!item.isCategoryMatch('defence') &&
                    !item.isCategoryMatch('police-defence')) {
                  return false;
                }
              } else if (tempChip == 'All India') {
                if (item.isAndamanJob) {
                  return false;
                }
              } else if (tempChip == 'Closing Soon') {
                final statusInfo = NjStatusBadge.computeStatus(
                  applicationLastDate: item.applicationLastDate,
                  statusOverride: item.statusOverride,
                );
                if (!statusInfo.label.contains('Closing') &&
                    !statusInfo.label.contains('Day Left')) {
                  return false;
                }
              }

              // Qualification
              if (tempQual != 'All') {
                final itemQual = item.qualification.toLowerCase();
                final filter = tempQual.toLowerCase().replaceAll(' pass', '');
                if (!itemQual.contains(filter)) {
                  return false;
                }
              }

              // Location
              if (tempLoc != 'All') {
                if (tempLoc == 'Andaman & Nicobar' && !item.isAndamanJob) {
                  return false;
                }
                if (tempLoc == 'All India' && item.isAndamanJob) {
                  return false;
                }
              }

              // Job Type
              if (tempJobType != 'All') {
                if (tempJobType == 'Government' && !item.isGovernmentJob) {
                  return false;
                }
                if (tempJobType == 'Private' && !item.isPrivateJob) {
                  return false;
                }
              }

              // Status
              if (tempStatus != 'All') {
                final statusInfo = NjStatusBadge.computeStatus(
                  applicationLastDate: item.applicationLastDate,
                  statusOverride: item.statusOverride,
                );
                final isClosed =
                    statusInfo.label.toLowerCase().contains('closed');
                if (tempStatus == 'Open' ||
                    tempStatus == 'Live' ||
                    tempStatus == 'Open / Live') {
                  if (isClosed) {
                    return false;
                  }
                } else if (tempStatus == 'Closing Soon') {
                  if (!statusInfo.label.contains('Closing') &&
                      !statusInfo.label.contains('Day Left')) {
                    return false;
                  }
                } else if (tempStatus == 'Closed') {
                  if (!isClosed) {
                    return false;
                  }
                }
              }

              return true;
            }).length;

            Widget buildFilterChip({
              required String label,
              required bool isSelected,
              required VoidCallback onTap,
            }) {
              return Material(
                color: isSelected
                    ? AppColors.royalBlue
                    : (isDark
                        ? AppColors.darkSurfaceElevated
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.royalBlue
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filters',
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primaryNavy,
                              ),
                            ),
                            Text(
                              'Refine active job opportunities',
                              style: AppTypography.subtitle.copyWith(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempQual = 'All';
                              tempLoc = 'All';
                              tempJobType = 'All';
                              tempStatus = 'All';
                              tempChip = 'Latest';
                            });
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.royalBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Scrollable Filter Sections
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Exam Category
                            Text(
                              'EXAM CATEGORY',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
                                'Latest',
                                'A&N',
                                'SSC',
                                'Railway',
                                'Banking',
                                'Police',
                                'Defence',
                                'All India',
                              ].map((c) {
                                return buildFilterChip(
                                  label: c,
                                  isSelected: tempChip == c,
                                  onTap: () =>
                                      setSheetState(() => tempChip = c),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 2. Minimum Qualification
                            Text(
                              'MINIMUM QUALIFICATION',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
                                'ITI',
                                'Diploma',
                                'Graduate',
                                'Post Graduate',
                              ].map((q) {
                                return buildFilterChip(
                                  label: q,
                                  isSelected: tempQual == q,
                                  onTap: () =>
                                      setSheetState(() => tempQual = q),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 3. Location
                            Text(
                              'JOB LOCATION',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
                                'Andaman & Nicobar',
                                'All India',
                              ].map((loc) {
                                return buildFilterChip(
                                  label: loc,
                                  isSelected: tempLoc == loc,
                                  onTap: () =>
                                      setSheetState(() => tempLoc = loc),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 4. Job Sector
                            Text(
                              'JOB SECTOR',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
                                'Government',
                                'Private',
                              ].map((jt) {
                                return buildFilterChip(
                                  label: jt,
                                  isSelected: tempJobType == jt,
                                  onTap: () =>
                                      setSheetState(() => tempJobType = jt),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 5. Application Status
                            Text(
                              'APPLICATION STATUS',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
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
                                'Open / Live',
                                'Closing Soon',
                                'Closed',
                              ].map((st) {
                                return buildFilterChip(
                                  label: st,
                                  isSelected: tempStatus == st,
                                  onTap: () =>
                                      setSheetState(() => tempStatus = st),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sticky Bottom Buttons matching Screen 5
                    Row(
                      children: [
                        // Reset button
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                tempQual = 'All';
                                tempLoc = 'All';
                                tempJobType = 'All';
                                tempStatus = 'All';
                                tempChip = 'Latest';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Show Results (Count) button
                        Expanded(
                          flex: 4,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedQualification = tempQual;
                                _selectedLocation = tempLoc;
                                _selectedJobType = tempJobType;
                                _selectedStatus = tempStatus;
                                _selectedChip = tempChip;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.royalBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 2,
                              shadowColor:
                                  AppColors.royalBlue.withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Show Results ($count)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
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
    final allCategories = ref.watch(categoriesProvider);

    // Dynamically merge any categories from Firestore into the chip list
    final displayChips = List<String>.from(_chips);
    for (final cat in allCategories) {
      if (cat.isActive &&
          (cat.contentScope == null ||
              cat.contentScope == 'job' ||
              cat.contentScope == 'all') &&
          cat.slug != 'admit-cards' &&
          cat.slug != 'results' &&
          cat.slug != 'answer-keys' &&
          cat.slug != 'syllabus' &&
          cat.slug != 'articles') {
        final label = cat.displayName;
        if (!displayChips.any((c) =>
            c.toLowerCase() == label.toLowerCase() ||
            c.toLowerCase() == cat.name.toLowerCase() ||
            c.toLowerCase() == cat.slug.toLowerCase())) {
          displayChips.add(label);
        }
      }
    }

    // Filter jobs
    final filteredJobs = allContent.where((item) {
      if (item.contentType != 'government_job' &&
          item.contentType != 'private_job' &&
          item.contentType != 'andaman_job') {
        return false;
      }

      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = item.title.toLowerCase().contains(q) ||
            item.organization.toLowerCase().contains(q) ||
            item.jobRole.toLowerCase().contains(q) ||
            (item.department != null &&
                item.department!.toLowerCase().contains(q)) ||
            item.qualification.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // Chip Filter
      if (_selectedChip == 'Andaman' || _selectedChip == 'A&N') {
        if (!item.isAndamanJob) {
          return false;
        }
        if (_andamanSubFilter == 'Govt' && !item.isGovernmentJob) {
          return false;
        }
        if (_andamanSubFilter == 'Private' && !item.isPrivateJob) {
          return false;
        }
      } else if (_selectedChip == 'SSC') {
        if (!item.isCategoryMatch('ssc')) {
          return false;
        }
      } else if (_selectedChip == 'Railway') {
        if (!item.isCategoryMatch('railway')) {
          return false;
        }
      } else if (_selectedChip == 'Banking') {
        if (!item.isCategoryMatch('banking')) {
          return false;
        }
      } else if (_selectedChip == 'Police') {
        if (!item.isCategoryMatch('police') &&
            !item.isCategoryMatch('police-defence')) {
          return false;
        }
      } else if (_selectedChip == 'Defence') {
        if (!item.isCategoryMatch('defence') &&
            !item.isCategoryMatch('police-defence')) {
          return false;
        }
      } else if (_selectedChip == 'All India') {
        if (item.isAndamanJob) {
          return false;
        }
      } else if (_selectedChip == 'Closing Soon') {
        final statusInfo = NjStatusBadge.computeStatus(
          applicationLastDate: item.applicationLastDate,
          statusOverride: item.statusOverride,
        );
        if (!statusInfo.label.contains('Closing') &&
            !statusInfo.label.contains('Day Left')) {
          return false;
        }
      } else if (_selectedChip != 'Latest') {
        final slug = _selectedChip.toLowerCase().replaceAll(' ', '-');
        final catMatch = allCategories.where(
          (c) =>
              c.displayName.toLowerCase() == _selectedChip.toLowerCase() ||
              c.name.toLowerCase() == _selectedChip.toLowerCase() ||
              c.slug.toLowerCase() == slug,
        );
        final targetSlug = catMatch.isNotEmpty ? catMatch.first.slug : slug;
        if (!item.isCategoryMatch(targetSlug) &&
            !item.isCategoryMatch(slug) &&
            !item.isCategoryMatch(_selectedChip.toLowerCase()) &&
            !item.isCategoryMatch(_selectedChip)) {
          return false;
        }
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
        if (_selectedLocation == 'Andaman & Nicobar') {
          if (!item.isAndamanJob &&
              !item.location.toLowerCase().contains('andaman')) {
            return false;
          }
        } else if (_selectedLocation == 'All India') {
          if (item.isAndamanJob) {
            return false;
          }
        }
      }

      // Job Type Filter
      if (_selectedJobType != 'All') {
        if (_selectedJobType == 'Government' && !item.isGovernmentJob) {
          return false;
        }
        if (_selectedJobType == 'Private' && !item.isPrivateJob) {
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
            !statusInfo.label.contains('Closing') &&
            !statusInfo.label.contains('Day Left')) {
          return false;
        }
        if (_selectedStatus == 'Closed' && statusInfo.label != 'Closed') {
          return false;
        }
      }

      return true;
    }).toList();

    final hasActiveFilters = activeFilterCount > 0 || _searchQuery.isNotEmpty;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Government Jobs',
                        style: AppTypography.majorHeading.copyWith(
                          fontSize: 20,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                      ),
                      Text(
                        '${filteredJobs.length} opportunities available',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (hasActiveFilters)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedQualification = 'All';
                          _selectedLocation = 'All';
                          _selectedJobType = 'All';
                          _selectedStatus = 'All';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Search & Filter Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search jobs, posts, department...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.muted,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.muted,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child:
                                      const Icon(Icons.clear_rounded, size: 16),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFilterBottomSheet,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: activeFilterCount > 0
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurfaceElevated
                                : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeFilterCount > 0
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: activeFilterCount > 0
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Filters',
                            style: AppTypography.button.copyWith(
                              fontSize: 12,
                              color: activeFilterCount > 0
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.navy),
                            ),
                          ),
                          if (activeFilterCount > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$activeFilterCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips (Specification 50)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: displayChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = displayChips[index];
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
            if (_selectedChip == 'Andaman' || _selectedChip == 'A&N')
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
            if (hasActiveFilters)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Row(
                  children: [
                    Text(
                      'Active: ',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text('Query: $_searchQuery'),
                          onDeleted: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (_selectedQualification != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_selectedQualification),
                          onDeleted: () =>
                              setState(() => _selectedQualification = 'All'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (_selectedLocation != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_selectedLocation),
                          onDeleted: () =>
                              setState(() => _selectedLocation = 'All'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (_selectedJobType != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_selectedJobType),
                          onDeleted: () =>
                              setState(() => _selectedJobType = 'All'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (_selectedStatus != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(_selectedStatus),
                          onDeleted: () =>
                              setState(() => _selectedStatus = 'All'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),

            // Job List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  ref.invalidate(firestoreContentStreamProvider);
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                color: AppColors.primary,
                child: filteredJobs.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: NjEmptyState(
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
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
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
              ? (value == 'Private'
                  ? const Color(0xFF6366F1)
                  : AppColors.primary)
              : (isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9)),
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
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}
