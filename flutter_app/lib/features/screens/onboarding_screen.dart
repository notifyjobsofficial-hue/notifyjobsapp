import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_icon_container.dart';
import '../providers/user_preferences_provider.dart';

/// Screen 2: Onboarding Flow (1/3, 2/3, 3/3)
/// Visual direction matching approved mockup:
/// - Top bar: '<' back button, centered '1 / 3' progress indicator, thin blue progress line
/// - Step 1: "What are you preparing for?", 2-col grid (A&N, SSC, Railway, Banking, Police, Defence) + full-width (All Govt Jobs)
/// - Step 2: "What is your qualification?", 2-col grid (10th, 12th, ITI, Diploma, Graduate, Post Graduate)
/// - Step 3: "Preferred Location", 3 stacked cards (Andaman & Nicobar, All India, Both)
/// - Sticky bottom bar: 'Skip' text button on left, Royal Blue 'Next' / 'Get Started' button on right
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: 1/3, 1: 2/3, 2: 3/3

  final List<String> _selectedTargets = ['All Govt Jobs'];
  String _selectedQualification = 'Graduate';
  String _selectedLocation = 'Both';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTargetTapped(String target) {
    HapticFeedback.selectionClick();
    setState(() {
      if (target == 'All Govt Jobs') {
        _selectedTargets.clear();
        _selectedTargets.add('All Govt Jobs');
      } else {
        _selectedTargets.remove('All Govt Jobs');
        if (_selectedTargets.contains(target)) {
          _selectedTargets.remove(target);
          if (_selectedTargets.isEmpty) {
            _selectedTargets.add('All Govt Jobs');
          }
        } else {
          _selectedTargets.add(target);
        }
      }
    });
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < 2) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    await ref.read(userPreferencesProvider.notifier).completeOnboarding(
          targetExams: _selectedTargets,
          qualification: _selectedQualification,
          locationPreference: _selectedLocation,
        );
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _handleSkip() async {
    HapticFeedback.lightImpact();
    await ref.read(userPreferencesProvider.notifier).skipOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const totalSteps = 3;
    final progressFraction = (_currentStep + 1) / totalSteps;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching Mockup Screen 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back button (visible when step > 0)
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.primaryNavy,
                      onPressed: _previousStep,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Back',
                    )
                  else
                    const SizedBox(width: 40, height: 40),

                  const Spacer(),

                  // Centered Step counter "1 / 3"
                  Text(
                    '${_currentStep + 1} / $totalSteps',
                    style: AppTypography.subtitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.secondaryText,
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(width: 40, height: 40),
                ],
              ),
            ),

            // Thin Step Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.royalBlue,
                    ),
                  ),
                ),
              ),
            ),

            // Main Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Control via Next button
                onPageChanged: (page) => setState(() => _currentStep = page),
                children: [
                  _buildStep1TargetExams(isDark),
                  _buildStep2Qualification(isDark),
                  _buildStep3Location(isDark),
                ],
              ),
            ),

            // Bottom Sticky Navigation Bar matching Mockup
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: _handleSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTypography.button.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Next / Get Started button
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.royalBlue.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStep == 2 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentStep == 2
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 1: Preparing For (Mockup Screen 2)
  Widget _buildStep1TargetExams(bool isDark) {
    final targets = [
      {'name': 'A&N Jobs', 'variant': NjIconVariant.andamanJobs},
      {'name': 'SSC', 'variant': NjIconVariant.ssc},
      {'name': 'Railway', 'variant': NjIconVariant.railway},
      {'name': 'Banking', 'variant': NjIconVariant.banking},
      {'name': 'Police', 'variant': NjIconVariant.police},
      {'name': 'Defence', 'variant': NjIconVariant.defence},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you preparing for?',
            style: AppTypography.screenTitle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your main interest (You can change this later)',
            style: AppTypography.subtitle.copyWith(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 22),

          // 2-Column Grid for 6 Main Targets
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: targets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = targets[index];
              final name = item['name'] as String;
              final variant = item['variant'] as NjIconVariant;
              final isSelected = _selectedTargets.contains(name);

              return _buildGridChoiceCard(
                title: name,
                iconVariant: variant,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => _onTargetTapped(name),
              );
            },
          ),
          const SizedBox(height: 12),

          // Full-width card: All Govt Jobs
          _buildFullWidthChoiceCard(
            title: 'All Govt Jobs',
            subtitle: 'Explore all central & state vacancies',
            iconVariant: NjIconVariant.allGovtJobs,
            isSelected: _selectedTargets.contains('All Govt Jobs'),
            isDark: isDark,
            onTap: () => _onTargetTapped('All Govt Jobs'),
          ),
        ],
      ),
    );
  }

  /// Step 2: Qualification
  Widget _buildStep2Qualification(bool isDark) {
    final qualifications = [
      {'name': '10th Pass', 'variant': NjIconVariant.tenthPass},
      {'name': '12th Pass', 'variant': NjIconVariant.twelfthPass},
      {'name': 'ITI', 'variant': NjIconVariant.articles},
      {'name': 'Diploma', 'variant': NjIconVariant.articles},
      {'name': 'Graduate', 'variant': NjIconVariant.graduate},
      {'name': 'Post Graduate', 'variant': NjIconVariant.graduate},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your qualification?',
            style: AppTypography.screenTitle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your highest qualification to filter eligible openings',
            style: AppTypography.subtitle.copyWith(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 22),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: qualifications.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = qualifications[index];
              final name = item['name'] as String;
              final variant = item['variant'] as NjIconVariant;
              final isSelected = _selectedQualification == name ||
                  (_selectedQualification == 'Graduate' && name == 'Graduate');

              return _buildGridChoiceCard(
                title: name,
                iconVariant: variant,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedQualification = name);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Step 3: Preferred Location
  Widget _buildStep3Location(bool isDark) {
    final locations = [
      {
        'title': 'Both (Recommended)',
        'subtitle': 'Get updates for all eligible openings across India & A&N',
        'key': 'Both',
        'variant': NjIconVariant.allGovtJobs,
      },
      {
        'title': 'Andaman & Nicobar Islands',
        'subtitle': 'Dedicated focus on UT administration & local recruitments',
        'key': 'Andaman & Nicobar',
        'variant': NjIconVariant.andamanJobs,
      },
      {
        'title': 'All India / Central Govt',
        'subtitle':
            'National recruitments: SSC, UPSC, Railways, Banking & Defence',
        'key': 'All India',
        'variant': NjIconVariant.allIndia,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Job Location',
            style: AppTypography.screenTitle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the recruitment notifications you wish to prioritize',
            style: AppTypography.subtitle.copyWith(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 22),
          ...locations.map((loc) {
            final key = loc['key'] as String;
            final isSelected = _selectedLocation == key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFullWidthChoiceCard(
                title: loc['title'] as String,
                subtitle: loc['subtitle'] as String,
                iconVariant: loc['variant'] as NjIconVariant,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedLocation = key);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 2-Column Choice Card
  Widget _buildGridChoiceCard({
    required String title,
    required NjIconVariant iconVariant,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF);
    final inactiveBg = isDark ? AppColors.darkCard : AppColors.surface;

    return Material(
      color: isSelected ? activeBg : inactiveBg,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.royalBlue
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // Top Right Selected Indicator
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.royalBlue
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.06)),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
              ),

              // Centered Icon & Label
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NjCategoryIcon(
                      variant: iconVariant,
                      size: 46,
                      iconSize: 22,
                      borderRadius: 14,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.royalBlue)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full Width Choice Card (All Govt Jobs or Location options)
  Widget _buildFullWidthChoiceCard({
    required String title,
    required String subtitle,
    required NjIconVariant iconVariant,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF);
    final inactiveBg = isDark ? AppColors.darkCard : AppColors.surface;

    return Material(
      color: isSelected ? activeBg : inactiveBg,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.royalBlue
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              NjCategoryIcon(
                variant: iconVariant,
                size: 46,
                iconSize: 22,
                borderRadius: 14,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.royalBlue)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.royalBlue
                      : (isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.06)),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
