import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_model.dart';
import '../providers/content_providers.dart';
import '../providers/saved_jobs_provider.dart';
import '../providers/app_settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_badge.dart';
import '../../core/widgets/nj_button.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_info_tile.dart';
import '../../core/widgets/nj_job_card.dart';
import '../../core/widgets/nj_official_source_sheet.dart';
import '../../core/widgets/nj_section_header.dart';
import '../../core/widgets/nj_share_sheet.dart';
import '../../core/widgets/nj_status_badge.dart';
import '../../core/utils/normalization_utils.dart';

class JobDetailScreen extends ConsumerWidget {
  final String id;

  const JobDetailScreen({super.key, required this.id});

  Future<void> _launchExternalUrl(
      BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link is not available yet.')),
      );
      return;
    }
    String cleanedUrl = urlString.trim();
    if (!cleanedUrl.startsWith('http://') &&
        !cleanedUrl.startsWith('https://') &&
        !cleanedUrl.startsWith('tel:') &&
        !cleanedUrl.startsWith('mailto:')) {
      cleanedUrl = 'https://$cleanedUrl';
    }
    final uri = Uri.tryParse(cleanedUrl);
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  void _openOfficialSource(
    BuildContext context,
    WidgetRef ref,
    String? urlString,
    OfficialSourceType type,
  ) {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link is not available yet.')),
      );
      return;
    }
    final appSettings = ref.read(appSettingsProvider);
    NjOfficialSourceSheet.show(
      context,
      url: urlString,
      type: type,
      appSettings: appSettings,
      onProceed: () => _launchExternalUrl(context, urlString),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final job = ref.watch(contentByIdProvider(id));
    final isSaved = ref.watch(isSavedProvider(id));
    final appSettings = ref.watch(appSettingsProvider);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const NjEmptyState(
          title: 'Job Not Found',
          message: 'This post may have been removed or updated.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          job.organization.isNotEmpty ? job.organization : 'Job Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isSaved ? AppColors.royalBlue : null,
            ),
            tooltip: isSaved ? 'Remove from Saved' : 'Save Job',
            onPressed: () {
              ref.read(savedJobsProvider.notifier).toggleSaved(job);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Removed from saved jobs'
                        : 'Job saved for offline access',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => NjShareSheet.show(
              context,
              content: job,
              shareBaseUrl: appSettings.shareBaseUrl,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Blue Hero Header Card
            _buildHeroHeader(context, job, isDark),
            const SizedBox(height: 16),

            // 2. Overview Specifications (2x2 Grid)
            if (job.appDisplayControls.showOverview) ...[
              if (job.isPrivateJob) ...[
                _buildPrivateOverview(context, job, isDark),
              ] else ...[
                _buildGovtOverview(context, job, isDark),
              ],
              const SizedBox(height: 18),
            ],

            // 3. Important Dates (Table / Highlighted Last Date)
            if (job.appDisplayControls.showImportantDates &&
                _hasImportantDates(job)) ...[
              const NjSectionHeader(
                title: 'Important Dates',
                icon: Icons.event_note_rounded,
              ),
              const SizedBox(height: 8),
              _buildImportantDatesCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 4. Vacancies Breakdown / Post Details
            if ((job.appDisplayControls.showPosts ||
                    job.appDisplayControls.showVacancies) &&
                (job.posts.isNotEmpty ||
                    job.vacanciesBreakdown.isNotEmpty ||
                    job.vacancies.trim().isNotEmpty)) ...[
              const NjSectionHeader(
                title: 'Vacancy & Post Details',
                icon: Icons.view_list_rounded,
              ),
              const SizedBox(height: 8),
              _buildVacanciesCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 5. Qualification / Eligibility Criteria
            if (job.appDisplayControls.showQualification &&
                (job.qualification.trim().isNotEmpty ||
                    (job.eligibilitySummary?.trim().isNotEmpty ?? false))) ...[
              const NjSectionHeader(
                title: 'Educational Qualification & Eligibility',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 8),
              _buildQualificationCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 6. Age Limit (Minimum Age, Maximum Age, Age As On, Relaxation)
            if (job.appDisplayControls.showAgeLimit &&
                (job.ageLimits.isNotEmpty ||
                    job.defaultMinimumAge != null ||
                    job.defaultMaximumAge != null)) ...[
              const NjSectionHeader(
                title: 'Age Limit & Relaxations',
                icon: Icons.hourglass_bottom_rounded,
              ),
              const SizedBox(height: 8),
              _buildAgeLimitCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 7. Application Fee
            if (job.appDisplayControls.showFees &&
                job.applicationFees.isNotEmpty) ...[
              const NjSectionHeader(
                title: 'Application Fees',
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 8),
              _buildApplicationFeeCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 8. Salary / Pay Scale
            if (job.appDisplayControls.showSalary && _hasSalaryInfo(job)) ...[
              const NjSectionHeader(
                title: 'Salary & Pay Level',
                icon: Icons.currency_rupee_rounded,
              ),
              const SizedBox(height: 8),
              _buildSalaryCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 9. Documents Required
            if (job.appDisplayControls.showDocuments &&
                (job.documents.isNotEmpty ||
                    job.uploadRequirements != null)) ...[
              const NjSectionHeader(
                title: 'Required Documents & Upload Guidelines',
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: 8),
              _buildDocumentsCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 10. Exam Details & Pattern
            if ((job.appDisplayControls.showExamDetails ||
                    job.appDisplayControls.showExamPattern) &&
                ((job.examDetails?.hasExam ?? false) ||
                    job.examPattern.isNotEmpty)) ...[
              const NjSectionHeader(
                title: 'Exam Details & Pattern',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 8),
              _buildExamDetailsCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 11. Syllabus Topics
            if (job.appDisplayControls.showSyllabus &&
                (job.syllabusTopics.isNotEmpty ||
                    (job.syllabusPdfUrl?.trim().isNotEmpty ?? false))) ...[
              const NjSectionHeader(
                title: 'Syllabus & Topics',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(height: 8),
              _buildSyllabusCard(context, job, isDark),
              const SizedBox(height: 18),
            ],

            // 12. Selection Process
            if (job.appDisplayControls.showSelectionProcess &&
                (job.selectionProcess.isNotEmpty ||
                    job.selectionRules != null)) ...[
              const NjSectionHeader(
                title: 'Selection Process & Rules',
                icon: Icons.fact_check_outlined,
              ),
              const SizedBox(height: 8),
              _buildSelectionProcessCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 13. How to Apply & Guidelines (Non-duplicated)
            if (job.appDisplayControls.showApplicationProcess &&
                _hasNonDuplicatedBody(job)) ...[
              NjSectionHeader(
                title: job.isPrivateJob
                    ? 'Job Description & Duties'
                    : 'How to Apply & Important Instructions',
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 8),
              _buildHowToApplyCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // Private Job Requirements (if applicable)
            if (job.isPrivateJob &&
                (job.requirements?.trim().isNotEmpty ?? false)) ...[
              const NjSectionHeader(
                title: 'Requirements & Skills',
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: 8),
              NjCard(
                child: Text(
                  job.requirements!.trim(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 14. Important Official Links (Prominent Action Buttons, No Raw URLs)
            if (job.appDisplayControls.showImportantLinks) ...[
              const NjSectionHeader(
                title: 'Important Official Links',
                icon: Icons.link_rounded,
              ),
              const SizedBox(height: 8),
              _buildImportantLinksCard(context, ref, job, isDark),
              const SizedBox(height: 18),
            ],

            // 15. Frequently Asked Questions (Accordion)
            if (job.appDisplayControls.showFAQ && job.faqs.isNotEmpty) ...[
              const NjSectionHeader(
                title: 'Frequently Asked Questions',
                icon: Icons.quiz_outlined,
              ),
              const SizedBox(height: 8),
              _buildFaqSection(job, isDark),
              const SizedBox(height: 18),
            ],

            // 16. Source Information & Editorial Verification
            if (job.appDisplayControls.showSourceInformation &&
                (job.sourceVerification != null ||
                    job.isReviewed ||
                    (job.sourceOrg?.trim().isNotEmpty ?? false))) ...[
              _buildSourceVerificationCard(job, isDark),
              const SizedBox(height: 18),
            ],

            // 17. Official Source Disclaimer
            if (job.appDisplayControls.showDisclaimer) ...[
              _buildDisclaimerCard(job, isDark),
              const SizedBox(height: 24),
            ],

            // 18. Related Opportunities
            _buildRelatedJobsSection(context, job),
          ],
        ),
      ),

      // 15. Sticky Bottom Action Bar
      bottomSheet: _buildStickyBottomDock(context, ref, job, isSaved, isDark),
    );
  }

  // ===========================================================================
  // SUB-SECTION BUILDERS
  // ===========================================================================

  bool _hasImportantDates(ContentModel job) {
    return job.importantDates.isNotEmpty ||
        (job.applicationStartDate != null &&
            job.applicationStartDate!.isNotEmpty) ||
        (job.applicationLastDate != null &&
            job.applicationLastDate!.isNotEmpty) ||
        (job.feePaymentLastDate != null &&
            job.feePaymentLastDate!.isNotEmpty) ||
        (job.correctionStartDate != null &&
            job.correctionStartDate!.isNotEmpty);
  }

  bool _hasSalaryInfo(ContentModel job) {
    return job.salary.trim().isNotEmpty ||
        (job.payLevel?.trim().isNotEmpty ?? false) ||
        (job.payScale?.trim().isNotEmpty ?? false) ||
        (job.salaryText?.trim().isNotEmpty ?? false) ||
        (job.salaryMin != null && job.salaryMin!.isNotEmpty) ||
        (job.salaryMax != null && job.salaryMax!.isNotEmpty);
  }

  bool _hasNonDuplicatedBody(ContentModel job) {
    if (job.howToApplySteps.isNotEmpty) return true;
    if (job.isPrivateJob) {
      return (job.jobDescription?.trim().isNotEmpty ?? false) ||
          job.body.trim().isNotEmpty;
    }
    // Only display body if it provides actual text and doesn't just replicate structured tables
    final b = job.body.trim();
    if (b.isEmpty) return false;
    if (job.posts.isNotEmpty && b.length < 30) return false;
    return true;
  }

  Widget _buildHeroHeader(BuildContext context, ContentModel job, bool isDark) {
    return NjCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: NjBadge(
                  label: job.jobTypeName ?? job.categoryDisplay,
                  variant: job.isAndamanJob
                      ? (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.blue)
                      : (job.isPrivateJob
                          ? NjBadgeVariant.purple
                          : NjBadgeVariant.primary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NjStatusBadge(
                  contentType: job.contentType,
                  applicationLastDate: job.applicationLastDate,
                  statusOverride: job.statusOverride,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            job.isPrivateJob
                ? (job.companyName ?? job.organization)
                : job.organization,
            style: AppTypography.titleSmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!job.isPrivateJob &&
              job.department != null &&
              job.department!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              job.department!,
              style: AppTypography.captionMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
            ),
          ],
          if (job.advtNo != null && job.advtNo!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 0.8,
                ),
              ),
              child: Text(
                'Advt / Ref: ${job.advtNo}',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  size: 16, color: AppColors.royalBlue),
              const SizedBox(width: 6),
              Text(
                job.isPrivateJob
                    ? 'Verified Employer Listing'
                    : 'Verified Official Recruitment',
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (job.views > 0) ...[
                const Spacer(),
                Icon(
                  Icons.visibility_outlined,
                  size: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${job.views} views',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovtOverview(
      BuildContext context, ContentModel job, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NjInfoTile(
                icon: Icons.groups_outlined,
                title: 'Total Vacancies',
                value: job.vacancies.isNotEmpty
                    ? job.displayVacancies
                    : 'Not Specified',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NjInfoTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Salary / Pay Level',
                value: job.salary.isNotEmpty ? job.salary : 'As per Govt Norms',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: NjInfoTile(
                icon: Icons.calendar_today_outlined,
                title: 'Last Date to Apply',
                value: job.displayLastDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NjInfoTile(
                icon: Icons.place_outlined,
                title: 'Job Location',
                value: job.location.isNotEmpty ? job.location : 'All India',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivateOverview(
      BuildContext context, ContentModel job, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NjInfoTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Salary / Compensation',
                value: (job.salaryRange?.isNotEmpty ?? false)
                    ? job.salaryRange!
                    : (job.salary.isNotEmpty ? job.salary : 'Best in Industry'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NjInfoTile(
                icon: Icons.place_outlined,
                title: 'Island / Location',
                value: (job.island?.isNotEmpty ?? false)
                    ? job.island!
                    : (job.location.isNotEmpty ? job.location : 'Andaman'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: NjInfoTile(
                icon: Icons.work_outline_rounded,
                title: 'Experience Required',
                value: (job.experience?.isNotEmpty ?? false)
                    ? job.experience!
                    : 'Fresher / Experienced',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NjInfoTile(
                icon: Icons.access_time_rounded,
                title: 'Employment Type',
                value: job.employmentType ?? 'Full Time',
              ),
            ),
          ],
        ),
        if (job.contactPhone != null ||
            job.contactEmail != null ||
            job.whatsappApplyUrl != null) ...[
          const SizedBox(height: 14),
          _buildEmployerContactCard(context, job, isDark),
        ],
      ],
    );
  }

  Widget _buildEmployerContactCard(
      BuildContext context, ContentModel job, bool isDark) {
    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone_rounded,
                  size: 16, color: AppColors.royalBlue),
              const SizedBox(width: 6),
              Text(
                'Direct Employer Contact',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (job.contactPhone != null && job.contactPhone!.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_rounded,
                    color: Color(0xFF0284C7), size: 18),
              ),
              title: Text(job.contactPhone!, style: AppTypography.titleSmall),
              subtitle: const Text('Call Employer directly',
                  style: AppTypography.captionMedium),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.call, size: 14),
                label: const Text('Call', style: TextStyle(fontSize: 12)),
                onPressed: () =>
                    _launchExternalUrl(context, 'tel:${job.contactPhone}'),
              ),
            ),
          ],
          if (job.whatsappApplyUrl != null &&
              job.whatsappApplyUrl!.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble_rounded,
                    color: Color(0xFF16A34A), size: 18),
              ),
              title:
                  const Text('WhatsApp Chat', style: AppTypography.titleSmall),
              subtitle: const Text('Message recruiter or send resume',
                  style: AppTypography.captionMedium),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Chat', style: TextStyle(fontSize: 12)),
                onPressed: () =>
                    _launchExternalUrl(context, job.whatsappApplyUrl),
              ),
            ),
          ],
          if (job.contactEmail != null && job.contactEmail!.isNotEmpty) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: Color(0xFF9333EA), size: 18),
              ),
              title: Text(job.contactEmail!, style: AppTypography.titleSmall),
              subtitle: const Text('Email Application',
                  style: AppTypography.captionMedium),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.mail, size: 14),
                label: const Text('Email', style: TextStyle(fontSize: 12)),
                onPressed: () =>
                    _launchExternalUrl(context, 'mailto:${job.contactEmail}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportantDatesCard(ContentModel job, bool isDark) {
    return NjCard(
      child: Column(
        children: [
          if (job.applicationStartDate != null &&
              job.applicationStartDate!.isNotEmpty)
            _buildDateRow(
              'Application Starts',
              NormalizationUtils.formatDate(job.applicationStartDate!),
              isDark: isDark,
            ),
          if (job.applicationLastDate != null &&
              job.applicationLastDate!.isNotEmpty)
            _buildDateRow(
              'Last Date to Apply',
              job.displayLastDate,
              isHighlight: true,
              isDark: isDark,
            ),
          if (job.feePaymentLastDate != null &&
              job.feePaymentLastDate!.isNotEmpty)
            _buildDateRow(
              'Fee Payment Last Date',
              NormalizationUtils.formatDate(job.feePaymentLastDate!),
              isDark: isDark,
            ),
          if (job.correctionStartDate != null &&
              job.correctionStartDate!.isNotEmpty)
            _buildDateRow(
              'Correction Window Starts',
              NormalizationUtils.formatDate(job.correctionStartDate!),
              isDark: isDark,
            ),
          if (job.correctionEndDate != null &&
              job.correctionEndDate!.isNotEmpty)
            _buildDateRow(
              'Correction Window Ends',
              NormalizationUtils.formatDate(job.correctionEndDate!),
              isDark: isDark,
            ),
          ...job.importantDates.map((d) {
            final formattedDate = NormalizationUtils.formatDate(d.date);
            return _buildDateRow(
              d.label,
              d.isTentative ? '$formattedDate (Tentative)' : formattedDate,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVacanciesCard(ContentModel job, bool isDark) {
    if (job.posts.isNotEmpty) {
      return Column(
        children: job.posts.map((post) {
          final nonZero = post.vacancies.nonZeroBreakdown;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NjCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.postName,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.royalBlue.withOpacity(0.2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          post.vacancies.total > 0
                              ? '${post.vacancies.total} ${post.vacancies.total == 1 ? "Post" : "Posts"}'
                              : 'Vacancies: Open',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((post.postCode?.isNotEmpty ?? false) ||
                      (post.group?.isNotEmpty ?? false) ||
                      (post.cadre?.isNotEmpty ?? false) ||
                      (post.department?.isNotEmpty ?? false) ||
                      (post.payLevel?.isNotEmpty ?? false) ||
                      (post.categoryName?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (post.postCode?.isNotEmpty ?? false)
                          _buildPostBadge('Code: ${post.postCode}', isDark),
                        if (post.group?.isNotEmpty ?? false)
                          _buildPostBadge(post.group!, isDark),
                        if (post.cadre?.isNotEmpty ?? false)
                          _buildPostBadge(post.cadre!, isDark),
                        if (post.department?.isNotEmpty ?? false)
                          _buildPostBadge(post.department!, isDark),
                        if (post.payLevel?.isNotEmpty ?? false)
                          _buildPostBadge('Pay: ${post.payLevel}', isDark),
                        if (post.categoryName?.isNotEmpty ?? false)
                          _buildPostBadge(post.categoryName!, isDark),
                      ],
                    ),
                  ],
                  if (post.qualification?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            post.qualification!.trim(),
                            style: AppTypography.caption.copyWith(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (post.desirableQualification?.trim().isNotEmpty ??
                      false) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star_outline_rounded,
                            size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Desirable: ${post.desirableQualification!.trim()}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? const Color(0xFFFCD34D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (post.ageMin != null || post.ageMax != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined,
                            size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Age: ${post.ageMin ?? "—"} to ${post.ageMax ?? "—"} yrs'
                            '${(post.femaleMaxAge != null && post.femaleMaxAge!.isNotEmpty) ? " (Female max: ${post.femaleMaxAge} yrs)" : ""}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (nonZero.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: nonZero.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    if (job.vacanciesBreakdown.isNotEmpty) {
      return NjCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? AppColors.darkSurfaceElevated
                    : const Color(0xFFEFF6FF),
              ),
              columns: const [
                DataColumn(
                    label: Text('Post Name', style: AppTypography.labelLarge)),
                DataColumn(
                    label: Text('Category', style: AppTypography.labelLarge)),
                DataColumn(
                    label: Text('Vacancies', style: AppTypography.labelLarge)),
                DataColumn(
                    label: Text('Pay Level', style: AppTypography.labelLarge)),
              ],
              rows: job.vacanciesBreakdown.map((item) {
                return DataRow(cells: [
                  DataCell(
                      Text(item.postName.isNotEmpty ? item.postName : '—')),
                  DataCell(
                      Text(item.category.isNotEmpty ? item.category : '—')),
                  DataCell(Text(item.count.isNotEmpty ? item.count : '—',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(item.payLevel ?? '—')),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
    }

    return NjCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.royalBlue.withOpacity(0.2)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: AppColors.royalBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Vacancies',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.displayVacancies,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildQualificationCard(ContentModel job, bool isDark) {
    final hasDetails = job.qualificationDetails != null &&
        job.qualificationDetails!.trim().isNotEmpty &&
        job.qualificationDetails!.trim() != job.qualification.trim();

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.royalBlue.withOpacity(0.2)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job.qualification.trim().isNotEmpty
                      ? job.qualification.trim()
                      : (job.eligibilitySummary?.trim().isNotEmpty == true
                          ? job.eligibilitySummary!.trim()
                          : 'Please refer to official notification for eligibility details.'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (hasDetails) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 8),
            Text(
              job.qualificationDetails!.trim(),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
                height: 1.45,
              ),
            ),
          ],
          if (job.experienceRequired?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              'Experience Required',
              job.experienceRequired!.trim(),
              isDark,
              icon: Icons.work_history_outlined,
            ),
          ],
          if (job.nationality?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Nationality / Citizenship',
              job.nationality!.trim(),
              isDark,
              icon: Icons.flag_outlined,
            ),
          ],
          if (job.registrationRequirement?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Council / Board Registration',
              job.registrationRequirement!.trim(),
              isDark,
              icon: Icons.verified_user_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeLimitCard(ContentModel job, bool isDark) {
    final hasCategoryLimits = job.ageLimits.isNotEmpty;
    final minAge = hasCategoryLimits
        ? job.ageLimits.first.minAge
        : (job.defaultMinimumAge ?? '18');
    final maxAge = hasCategoryLimits
        ? (job.ageLimits.first.maxAge ?? '30')
        : (job.defaultMaximumAge ?? '30');
    final ageAsOn =
        hasCategoryLimits ? job.ageLimits.first.ageAsOn : job.ageAsOn;

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age Summary Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.royalBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Minimum Age: $minAge Years • Maximum Age: $maxAge Years',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ageAsOn != null && ageAsOn.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Age calculated as on: ${NormalizationUtils.formatDate(ageAsOn)}',
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
            ),
          ],
          if (hasCategoryLimits) ...[
            const SizedBox(height: 12),
            // Categories Breakdown Table
            ...job.ageLimits.map((limit) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      limit.category.isNotEmpty
                          ? limit.category
                          : 'General / UR',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          limit.displayAge,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (limit.relaxationYears.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              limit.displayRelaxation,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ] else if (job.ageLimits.isNotEmpty &&
              job.ageLimits.first.relaxationYears.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Age Relaxation: ${job.ageLimits.first.relaxationYears}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationFeeCard(ContentModel job, bool isDark) {
    // Collect distinct payment modes once at bottom rather than repeating per row
    final distinctModes = job.applicationFees
        .map((f) => f.paymentMode?.trim())
        .whereType<String>()
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...job.applicationFees.map((fee) {
            final isFree = fee.amount == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fee.category.isNotEmpty ? fee.category : 'General',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFree
                          ? const Color(0xFFDCFCE7)
                          : (isDark
                              ? AppColors.darkSurfaceElevated
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isFree ? '₹0 (Nil)' : '₹${fee.amount}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFree
                            ? const Color(0xFF16A34A)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (distinctModes.isNotEmpty) ...[
            const Divider(height: 18),
            Row(
              children: [
                const Icon(Icons.payment_rounded,
                    size: 14, color: AppColors.royalBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Payment Mode: ${distinctModes.join(" / ")}',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSalaryCard(ContentModel job, bool isDark) {
    String salaryDisplay = job.salaryText?.trim() ?? '';
    if (salaryDisplay.isEmpty) {
      if ((job.salaryMin?.isNotEmpty ?? false) ||
          (job.salaryMax?.isNotEmpty ?? false)) {
        salaryDisplay =
            '₹${job.salaryMin ?? "—"} - ₹${job.salaryMax ?? "—"} per month';
      } else if (job.salary.trim().isNotEmpty) {
        salaryDisplay = job.salary.trim();
      }
    }

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (salaryDisplay.isNotEmpty)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.royalBlue.withOpacity(0.2)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.currency_rupee_rounded,
                    color: AppColors.royalBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remuneration / Pay',
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        salaryDisplay,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if ((job.payLevel?.trim().isNotEmpty ?? false) ||
              (job.payScale?.trim().isNotEmpty ?? false)) ...[
            if (salaryDisplay.isNotEmpty) const Divider(height: 20),
            if (job.payLevel?.trim().isNotEmpty ?? false)
              _buildInfoRow('Pay Level', job.payLevel!.trim(), isDark),
            if (job.payScale?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              _buildInfoRow('Pay Scale', job.payScale!.trim(), isDark),
            ],
          ],
          if (job.salaryRange?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Text(
              'Salary Range: ${job.salaryRange!.trim()}',
              style: AppTypography.caption.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(ContentModel job, bool isDark) {
    final upload = job.uploadRequirements;
    final hasUpload = upload != null &&
        ((upload.photographFormat?.isNotEmpty ?? false) ||
            (upload.photographMaxSize?.isNotEmpty ?? false) ||
            (upload.signatureFormat?.isNotEmpty ?? false) ||
            (upload.signatureMaxSize?.isNotEmpty ?? false) ||
            (upload.certificateFormat?.isNotEmpty ?? false) ||
            (upload.certificateMaxSize?.isNotEmpty ?? false));

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.documents.isNotEmpty) ...[
            ...job.documents.map((doc) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      doc.required
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: doc.required
                          ? const Color(0xFF16A34A)
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  doc.documentName,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: doc.required
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  doc.required ? 'Mandatory' : 'Optional',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: doc.required
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (doc.notes?.trim().isNotEmpty ?? false) ...[
                            const SizedBox(height: 2),
                            Text(
                              doc.notes!.trim(),
                              style: AppTypography.captionMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (hasUpload) ...[
            if (job.documents.isNotEmpty) const Divider(height: 20),
            Text(
              'Upload Guidelines & File Specifications',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            _buildUploadSpec('Photograph', upload.photographFormat,
                upload.photographMaxSize, isDark),
            const SizedBox(height: 6),
            _buildUploadSpec('Signature', upload.signatureFormat,
                upload.signatureMaxSize, isDark),
            const SizedBox(height: 6),
            _buildUploadSpec('Certificates / Docs', upload.certificateFormat,
                upload.certificateMaxSize, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildExamDetailsCard(ContentModel job, bool isDark) {
    final details = job.examDetails;

    return Column(
      children: [
        if (details != null && details.hasExam)
          NjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.examMode?.trim().isNotEmpty ?? false)
                  _buildInfoRow('Exam Mode', details.examMode!.trim(), isDark,
                      icon: Icons.computer_rounded),
                if (details.examType?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Exam Type', details.examType!.trim(), isDark,
                      icon: Icons.assignment_turned_in_outlined),
                ],
                if (details.examDuration?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Duration', details.examDuration!.trim(), isDark,
                      icon: Icons.timer_outlined),
                ],
                if (details.negativeMarking?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Negative Marking',
                      details.negativeMarking!.trim(), isDark,
                      icon: Icons.remove_circle_outline_rounded),
                ],
                if (details.minimumQualifyingMarks?.trim().isNotEmpty ??
                    false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Min. Qualifying Marks',
                      details.minimumQualifyingMarks!.trim(), isDark,
                      icon: Icons.grade_outlined),
                ],
                if ((details.examCentre?.trim().isNotEmpty ?? false) ||
                    (details.examLocation?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Exam Centre / Location',
                    (details.examCentre?.trim().isNotEmpty ?? false)
                        ? details.examCentre!.trim()
                        : details.examLocation!.trim(),
                    isDark,
                    icon: Icons.location_on_outlined,
                  ),
                ],
                if (details.examLanguage?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Medium / Language', details.examLanguage!.trim(), isDark,
                      icon: Icons.translate_rounded),
                ],
                if (details.admitCardMethod?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Admit Card Release',
                      details.admitCardMethod!.trim(), isDark,
                      icon: Icons.badge_outlined),
                ],
              ],
            ),
          ),
        if (job.examPattern.isNotEmpty) ...[
          if (details != null && details.hasExam) const SizedBox(height: 10),
          _buildExamPatternCard(job, isDark),
        ],
      ],
    );
  }

  Widget _buildSyllabusCard(
      BuildContext context, ContentModel job, bool isDark) {
    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.syllabusPdfUrl?.trim().isNotEmpty ?? false) ...[
            NjButton(
              label: 'Download Detailed Syllabus (PDF)',
              icon: Icons.picture_as_pdf_rounded,
              variant: NjButtonVariant.secondary,
              onPressed: () => _launchExternalUrl(context, job.syllabusPdfUrl!),
            ),
            if (job.syllabusTopics.isNotEmpty) const SizedBox(height: 14),
          ],
          if (job.syllabusTopics.isNotEmpty) ...[
            Text(
              'Topics & Syllabus Breakdown',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            ...job.syllabusTopics.map((topic) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (topic.subject?.isNotEmpty ?? false) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.royalBlue.withOpacity(0.2)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                topic.subject!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.royalBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              topic.topicName,
                              style: AppTypography.titleSmall.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (topic.details?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          topic.details!.trim(),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.secondaryText,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionProcessCard(ContentModel job, bool isDark) {
    final rules = job.selectionRules;
    final hasRules = rules != null &&
        ((rules.selectionBasis?.isNotEmpty ?? false) ||
            (rules.meritCalculation?.isNotEmpty ?? false) ||
            (rules.qualifyingCriteria?.isNotEmpty ?? false) ||
            (rules.documentVerificationRule?.isNotEmpty ?? false) ||
            (rules.waitingListRule?.isNotEmpty ?? false) ||
            (rules.reservationRule?.isNotEmpty ?? false) ||
            rules.tieBreakingRules.isNotEmpty);

    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.selectionProcess.isNotEmpty)
            ...job.selectionProcess.map((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDark
                          ? AppColors.royalBlue.withOpacity(0.2)
                          : const Color(0xFFEFF6FF),
                      child: Text(
                        '${step.stageNumber}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : AppColors.royalBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.name,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              step.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (hasRules) ...[
            if (job.selectionProcess.isNotEmpty) const Divider(height: 20),
            Text(
              'Selection Rules & Criteria',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            if (rules.selectionBasis?.isNotEmpty ?? false)
              _buildInfoRow('Selection Basis', rules.selectionBasis!, isDark),
            if (rules.meritCalculation?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                  'Merit List Preparation', rules.meritCalculation!, isDark),
            ],
            if (rules.qualifyingCriteria?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                  'Qualifying Criteria', rules.qualifyingCriteria!, isDark),
            ],
            if (rules.documentVerificationRule?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              _buildInfoRow('Document Verification',
                  rules.documentVerificationRule!, isDark),
            ],
            if (rules.waitingListRule?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                  'Waiting List Rule', rules.waitingListRule!, isDark),
            ],
            if (rules.tieBreakingRules.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tie-Breaking Rules:',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              ...rules.tieBreakingRules.map((rule) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Text('• $rule',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondaryText,
                        )),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExamPatternCard(ContentModel job, bool isDark) {
    return NjCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                  label: Text('Subject', style: AppTypography.labelLarge)),
              DataColumn(label: Text('Qs', style: AppTypography.labelLarge)),
              DataColumn(label: Text('Marks', style: AppTypography.labelLarge)),
            ],
            rows: job.examPattern.map((p) {
              return DataRow(cells: [
                DataCell(Text(p.subject)),
                DataCell(Text(p.questions)),
                DataCell(Text(p.marks,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceVerificationCard(ContentModel job, bool isDark) {
    final sv = job.sourceVerification;
    final isVerified = job.isReviewed || (sv?.sourceVerified == true);
    final advtNo =
        sv?.notificationNumber ?? job.notificationNumber ?? job.advtNumber;
    final org = sv?.sourceOrg ?? job.organization;

    return NjCard(
      color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVerified ? Icons.verified_rounded : Icons.source_outlined,
                size: 18,
                color:
                    isVerified ? const Color(0xFF16A34A) : AppColors.royalBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Source & Verification',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isVerified ? 'Reviewed by Notify Jobs' : 'Official Notice',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isVerified
                        ? const Color(0xFF16A34A)
                        : AppColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (advtNo != null && advtNo.isNotEmpty)
            _buildVerificationRow('Notification No.', advtNo, isDark),
          if (sv?.gazetteNumber != null && sv!.gazetteNumber!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildVerificationRow('Gazette No.', sv.gazetteNumber!, isDark),
          ],
          if (sv?.circularNumber != null && sv!.circularNumber!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildVerificationRow('Circular No.', sv.circularNumber!, isDark),
          ],
          if (org.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildVerificationRow('Issuing Authority', org, isDark),
          ],
          if (sv?.sourcePublishedDate != null &&
              sv!.sourcePublishedDate!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildVerificationRow(
              'Date Published',
              NormalizationUtils.formatDate(sv.sourcePublishedDate!),
              isDark,
            ),
          ],
          if (job.reviewedBy != null && job.reviewedBy!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildVerificationRow(
              'Editorial Review',
              'Checked by ${job.reviewedBy!}${job.reviewedAt != null ? " on ${NormalizationUtils.formatDate(job.reviewedAt!)}" : ""}',
              isDark,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Notify Jobs is an independent curator and is not affiliated with the recruiting authority. Information is verified against official public releases.',
            style: AppTypography.caption.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 6),
        ],
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSpec(
      String label, String? format, String? size, bool isDark) {
    if ((format == null || format.isEmpty) && (size == null || size.isEmpty)) {
      return const SizedBox.shrink();
    }
    final text = [
      if (format != null && format.isNotEmpty) 'Format: $format',
      if (size != null && size.isNotEmpty) 'Max Size: $size',
    ].join(' • ');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          text,
          style: AppTypography.captionMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.secondaryText,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowToApplyCard(ContentModel job, bool isDark) {
    if (job.howToApplySteps.isNotEmpty) {
      return NjCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < job.howToApplySteps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDark
                          ? AppColors.royalBlue.withOpacity(0.2)
                          : const Color(0xFFEFF6FF),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : AppColors.royalBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        job.howToApplySteps[i].trim(),
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    final text = job.isPrivateJob
        ? (job.jobDescription?.trim().isNotEmpty == true
            ? job.jobDescription!.trim()
            : job.body.trim())
        : job.body.trim();

    return NjCard(
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImportantLinksCard(
      BuildContext context, WidgetRef ref, ContentModel job, bool isDark) {
    return NjCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Direct Apply Online Button
          if (job.applyUrl != null && job.applyUrl!.trim().isNotEmpty) ...[
            NjButton(
              label: 'Apply Online (Official Link)',
              icon: Icons.open_in_browser_rounded,
              onPressed: () => _openOfficialSource(
                context,
                ref,
                job.applyUrl,
                OfficialSourceType.apply,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 2. Official PDF Notification Download Button
          if (job.officialNotificationUrl != null &&
              job.officialNotificationUrl!.trim().isNotEmpty) ...[
            NjButton(
              label: 'Download Official Notification (PDF)',
              icon: Icons.download_rounded,
              variant: NjButtonVariant.secondary,
              onPressed: () => _openOfficialSource(
                context,
                ref,
                job.officialNotificationUrl,
                OfficialSourceType.notification,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 3. Official Website Button
          if (job.officialWebsiteUrl != null &&
              job.officialWebsiteUrl!.trim().isNotEmpty) ...[
            NjButton(
              label: 'Visit Official Website',
              icon: Icons.language_rounded,
              variant: NjButtonVariant.outline,
              onPressed: () => _openOfficialSource(
                context,
                ref,
                job.officialWebsiteUrl,
                OfficialSourceType.website,
              ),
            ),
          ],

          // 4. Extra Custom Structured Links
          ...job.importantLinks.where((link) {
            return link.url.trim().isNotEmpty &&
                link.url != job.applyUrl &&
                link.url != job.officialNotificationUrl &&
                link.url != job.officialWebsiteUrl;
          }).map((link) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: NjButton(
                label: link.title.isNotEmpty ? link.title : 'Open Link',
                icon: Icons.link_rounded,
                variant: NjButtonVariant.outline,
                onPressed: () => _launchExternalUrl(context, link.url),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFaqSection(ContentModel job, bool isDark) {
    return Column(
      children: job.faqs.map((faq) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NjCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 12),
              title: Text(
                faq.question,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
              ),
              children: [
                Text(
                  faq.answer,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDisclaimerCard(ContentModel job, bool isDark) {
    return NjCard(
      color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 17, color: AppColors.royalBlue),
              const SizedBox(width: 8),
              Text(
                'Official Source Disclaimer',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Information is curated from the official advertisement published by ${job.organization.isNotEmpty ? job.organization : "the recruiting authority"}. '
            'Notify Jobs is an independent platform and does not represent any government entity. '
            'Candidates are advised to cross-verify all details, eligibility criteria, and deadlines on the official recruitment website.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          if (job.lastVerifiedAt != null &&
              job.lastVerifiedAt!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Last Verified: ${NormalizationUtils.formatDate(job.lastVerifiedAt!)}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedJobsSection(BuildContext context, ContentModel job) {
    return Consumer(
      builder: (context, ref, child) {
        final relatedList = ref.watch(
          categoryContentProvider(
            CategoryContentParams(category: job.contentType, limit: 3),
          ),
        );
        final filtered =
            relatedList.where((item) => item.id != job.id).take(2).toList();
        if (filtered.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NjSectionHeader(
              title: 'Related Opportunities',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 8),
            ...filtered.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NjJobCard(
                    job: item,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(id: item.id),
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildStickyBottomDock(BuildContext context, WidgetRef ref,
      ContentModel job, bool isSaved, bool isDark) {
    final appSettings = ref.watch(appSettingsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton.filledTonal(
              icon: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSaved
                    ? AppColors.royalBlue
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              ),
              onPressed: () {
                ref.read(savedJobsProvider.notifier).toggleSaved(job);
              },
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => NjShareSheet.show(
                context,
                content: job,
                shareBaseUrl: appSettings.shareBaseUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: job.isPrivateJob &&
                      (job.whatsappApplyUrl?.isNotEmpty ?? false)
                  ? NjButton(
                      label: 'Apply via WhatsApp',
                      icon: Icons.chat_bubble_rounded,
                      onPressed: () =>
                          _launchExternalUrl(context, job.whatsappApplyUrl),
                    )
                  : job.isPrivateJob && (job.contactPhone?.isNotEmpty ?? false)
                      ? NjButton(
                          label: 'Call Employer',
                          icon: Icons.phone_rounded,
                          onPressed: () => _launchExternalUrl(
                              context, 'tel:${job.contactPhone}'),
                        )
                      : NjButton(
                          label: 'Apply Online',
                          icon: Icons.open_in_new_rounded,
                          onPressed: () => _openOfficialSource(
                            context,
                            ref,
                            job.applyUrl ?? job.officialWebsiteUrl,
                            OfficialSourceType.apply,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value,
      {bool isHighlight = false, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isHighlight ? 8 : 6,
        horizontal: isHighlight ? 10 : 0,
      ),
      margin: EdgeInsets.symmetric(vertical: isHighlight ? 3 : 0),
      decoration: isHighlight
          ? BoxDecoration(
              color: isDark
                  ? const Color(0xFF7F1D1D).withOpacity(0.3)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                width: 1,
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                if (isHighlight) ...[
                  const Icon(Icons.timer_outlined,
                      size: 14, color: Color(0xFFDC2626)),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: isHighlight
                        ? AppTypography.labelLarge.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                          )
                        : AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: isHighlight
                  ? AppTypography.titleSmall.copyWith(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    )
                  : AppTypography.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
