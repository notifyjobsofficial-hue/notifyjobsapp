import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';

/// Seed initial published content for instant cold launch and offline resilience
const _initialContent = <ContentModel>[
  ContentModel(
    id: 'ssc-cgl-2026',
    contentType: 'government_job',
    title: 'SSC CGL 2026 Notification - 8,200 Group B & C Vacancies',
    slug: 'ssc-cgl-2026-notification',
    excerpt:
        'Staff Selection Commission has announced 8,200 vacancies for Assistant Section Officer, Inspector, and Tax Assistant.',
    body:
        '## SSC Combined Graduate Level Examination 2026\n\nStaff Selection Commission (SSC) conducts the Combined Graduate Level (CGL) examination for recruitment to various Group B and Group C posts in ministries, departments, and organizations of the Government of India.\n\n### Key Highlights\n- **Post Names**: Assistant Section Officer, Inspector of Central Excise, Preventive Officer, Sub Inspector (CBI), Tax Assistant.\n- **Eligibility**: Bachelor Degree from any recognized university.\n- **Mode of Exam**: Computer Based Test (Tier 1 and Tier 2).',
    organization: 'Staff Selection Commission (SSC)',
    department: 'Department of Personnel and Training (DoPT)',
    jobRole: 'Group B & C Officers',
    vacancies: '8,200',
    qualification: 'Graduation in any stream',
    salary: '₹35,400 - ₹1,12,400 (Level 4 to Level 7)',
    location: 'All India',
    jobType: 'Regular Central Govt',
    applicationStartDate: '2026-09-01',
    applicationLastDate: '2026-09-30',
    statusOverride: 'auto',
    officialWebsiteUrl: 'https://ssc.gov.in',
    officialNotificationUrl: 'https://ssc.gov.in/notices/cgl_2026.pdf',
    applyUrl: 'https://ssc.gov.in/apply',
    importantDates: const [
      ImportantDateModel(
          id: '1', label: 'Notification Release', date: '01 Sep 2026'),
      ImportantDateModel(
          id: '2', label: 'Application Start', date: '01 Sep 2026'),
      ImportantDateModel(
          id: '3', label: 'Last Date to Apply', date: '30 Sep 2026'),
      ImportantDateModel(
          id: '4',
          label: 'Tier 1 Exam Date',
          date: 'Nov/Dec 2026',
          isTentative: true),
    ],
    vacanciesBreakdown: const [
      VacancyItemModel(
          id: '1',
          postName: 'Assistant Section Officer',
          category: 'UR/OBC/SC/ST/EWS',
          count: '1,850',
          payLevel: 'Level 7'),
      VacancyItemModel(
          id: '2',
          postName: 'Inspector (Central Excise)',
          category: 'UR/OBC/SC/ST/EWS',
          count: '2,200',
          payLevel: 'Level 7'),
      VacancyItemModel(
          id: '3',
          postName: 'Tax Assistant',
          category: 'UR/OBC/SC/ST/EWS',
          count: '1,450',
          payLevel: 'Level 4'),
      VacancyItemModel(
          id: '4',
          postName: 'Sub Inspector (CBI)',
          category: 'UR/OBC/SC/ST/EWS',
          count: '320',
          payLevel: 'Level 7'),
    ],
    ageLimits: const [
      AgeLimitModel(
          id: '1',
          category: 'General / UR',
          relaxationYears: 'None',
          maxAge: '30 Years'),
      AgeLimitModel(
          id: '2',
          category: 'OBC (Non-Creamy Layer)',
          relaxationYears: '3 Years',
          maxAge: '33 Years'),
      AgeLimitModel(
          id: '3',
          category: 'SC / ST',
          relaxationYears: '5 Years',
          maxAge: '35 Years'),
    ],
    applicationFees: const [
      ApplicationFeeModel(
          id: '1',
          category: 'General / OBC / EWS (Male)',
          fee: '₹100',
          paymentMode: 'Online Netbanking / UPI / Card'),
      ApplicationFeeModel(
          id: '2',
          category: 'SC / ST / PwD / ESM / All Females',
          fee: 'Exempted (₹0)',
          paymentMode: 'N/A'),
    ],
    selectionProcess: const [
      SelectionStepModel(
          id: '1',
          stageNumber: 1,
          name: 'Tier 1 Examination',
          description:
              'Objective Computer Based Test (CBT) covering Reasoning, GA, Quant, and English.'),
      SelectionStepModel(
          id: '2',
          stageNumber: 2,
          name: 'Tier 2 Examination',
          description:
              'Subject Paper CBT + Computer Proficiency Test (DEST) Data Entry Speed Test.'),
      SelectionStepModel(
          id: '3',
          stageNumber: 3,
          name: 'Document Verification',
          description:
              'Scrutiny of original educational and caste certificates by user departments.'),
    ],
    examPattern: const [
      ExamPatternModel(
          id: '1',
          subject: 'General Intelligence & Reasoning',
          questions: '25',
          marks: '50',
          duration: '60 Mins Total'),
      ExamPatternModel(
          id: '2', subject: 'General Awareness', questions: '25', marks: '50'),
      ExamPatternModel(
          id: '3',
          subject: 'Quantitative Aptitude',
          questions: '25',
          marks: '50'),
      ExamPatternModel(
          id: '4',
          subject: 'English Comprehension',
          questions: '25',
          marks: '50'),
    ],
    importantLinks: const [
      ImportantLinkModel(
          id: '1',
          title: 'Apply Online (Direct Link)',
          url: 'https://ssc.gov.in/apply',
          type: 'apply_online'),
      ImportantLinkModel(
          id: '2',
          title: 'Official Notification PDF',
          url: 'https://ssc.gov.in/notices/cgl_2026.pdf',
          type: 'official_notification'),
      ImportantLinkModel(
          id: '3',
          title: 'Official SSC Portal',
          url: 'https://ssc.gov.in',
          type: 'official_website'),
    ],
    faqs: const [
      FAQModel(
          id: '1',
          question: 'What is the minimum qualification for SSC CGL?',
          answer:
              'Candidates must possess a Bachelor Degree in any discipline from a recognized University.'),
      FAQModel(
          id: '2',
          question: 'Is there any negative marking in Tier 1?',
          answer:
              'Yes, 0.50 marks will be deducted for each incorrect answer.'),
    ],
    sourceOrg: 'Staff Selection Commission (Official Website)',
    sourceUrl: 'https://ssc.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-01T10:00:00.000Z',
    updatedAt: '2026-09-10T14:30:00.000Z',
    views: 14280,
    categoryIds: const ['latest-jobs', 'ssc'],
    tags: const ['ssc', 'cgl', 'graduate', 'central-govt'],
  ),
  ContentModel(
    id: 'andaman-police-si-2026',
    contentType: 'government_job',
    title: 'Andaman & Nicobar Police SI & Constable Recruitment 2026',
    slug: 'andaman-nicobar-police-recruitment-2026',
    excerpt:
        'Andaman & Nicobar Police Department announces 340 vacancies for Sub-Inspector and Constable posts in Port Blair.',
    body:
        '## Andaman and Nicobar Police Recruitment 2026\n\nApplications are invited from eligible candidates for filling up Sub-Inspector and Constable vacancies in Andaman & Nicobar Police Force.\n\n### Eligibility Criteria\n- Local candidates possessing valid residency certificate of A&N Islands.\n- Physical measurement and fitness tests apply as per standard service rules.',
    organization: 'Andaman & Nicobar Police',
    department: 'Director General of Police, Port Blair',
    jobRole: 'Sub-Inspector & Constable',
    vacancies: '340',
    qualification: '12th Pass / Graduate',
    salary: '₹21,700 - ₹69,100 (Level 3 to Level 6)',
    location: 'Port Blair, Andaman & Nicobar',
    jobType: 'UT Administration Regular',
    applicationStartDate: '2026-09-05',
    applicationLastDate: '2026-10-05',
    statusOverride: 'auto',
    officialWebsiteUrl: 'https://police.andaman.gov.in',
    officialNotificationUrl:
        'https://police.andaman.gov.in/recruitment_2026.pdf',
    applyUrl: 'https://police.andaman.gov.in/online',
    importantDates: const [
      ImportantDateModel(
          id: '1', label: 'Online Application Opens', date: '05 Sep 2026'),
      ImportantDateModel(
          id: '2', label: 'Last Date to Submit Online', date: '05 Oct 2026'),
      ImportantDateModel(
          id: '3',
          label: 'Physical Endurance Test',
          date: 'November 2026',
          isTentative: true),
    ],
    vacanciesBreakdown: const [
      VacancyItemModel(
          id: '1',
          postName: 'Sub-Inspector (Executive)',
          category: 'Island Residents',
          count: '45',
          payLevel: 'Level 6'),
      VacancyItemModel(
          id: '2',
          postName: 'Police Constable',
          category: 'Island Residents',
          count: '295',
          payLevel: 'Level 3'),
    ],
    ageLimits: const [
      AgeLimitModel(
          id: '1',
          category: 'Male (General)',
          relaxationYears: 'Standard',
          maxAge: '25 Years'),
      AgeLimitModel(
          id: '2',
          category: 'Female (General)',
          relaxationYears: 'Standard',
          maxAge: '28 Years'),
      AgeLimitModel(
          id: '3',
          category: 'OBC / Tribals of A&N',
          relaxationYears: '3 to 5 Years',
          maxAge: '30 Years'),
    ],
    applicationFees: const [
      ApplicationFeeModel(
          id: '1',
          category: 'All Applicants',
          fee: '₹0 (No Application Fee)',
          paymentMode: 'Exempted'),
    ],
    selectionProcess: const [
      SelectionStepModel(
          id: '1',
          stageNumber: 1,
          name: 'Physical Endurance & Measurement Test (PE&MT)',
          description: 'Running, Long Jump, High Jump.'),
      SelectionStepModel(
          id: '2',
          stageNumber: 2,
          name: 'Written Examination',
          description:
              'Objective test of 100 marks covering GK, Reasoning, and Elementary Mathematics.'),
      SelectionStepModel(
          id: '3',
          stageNumber: 3,
          name: 'Medical Examination',
          description: 'Fitness verification at GB Pant Hospital, Port Blair.'),
    ],
    examPattern: const [
      ExamPatternModel(
          id: '1',
          subject: 'General Knowledge & Current Affairs',
          questions: '40',
          marks: '40',
          duration: '90 Mins'),
      ExamPatternModel(
          id: '2',
          subject: 'Reasoning & Aptitude',
          questions: '30',
          marks: '30'),
      ExamPatternModel(
          id: '3',
          subject: 'Elementary Mathematics',
          questions: '30',
          marks: '30'),
    ],
    importantLinks: const [
      ImportantLinkModel(
          id: '1',
          title: 'Apply Online',
          url: 'https://police.andaman.gov.in/online',
          type: 'apply_online'),
      ImportantLinkModel(
          id: '2',
          title: 'Official Notification PDF',
          url: 'https://police.andaman.gov.in/recruitment_2026.pdf',
          type: 'official_notification'),
      ImportantLinkModel(
          id: '3',
          title: 'Police Official Portal',
          url: 'https://police.andaman.gov.in',
          type: 'official_website'),
    ],
    faqs: const [
      FAQModel(
          id: '1',
          question: 'Who can apply for A&N Police Constable?',
          answer:
              'Candidates must be 12th pass and permanent residents of Andaman and Nicobar Islands.'),
    ],
    sourceOrg: 'A&N Police Headquarters, Port Blair',
    sourceUrl: 'https://police.andaman.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-05T09:00:00.000Z',
    updatedAt: '2026-09-11T12:00:00.000Z',
    views: 8940,
    categoryIds: const ['latest-jobs', 'andaman-nicobar', 'police-defence'],
    tags: const ['andaman', 'police', 'port-blair', 'constable'],
  ),
  ContentModel(
    id: 'rrb-ntpc-2026-admit-card',
    contentType: 'admit_card',
    title: 'RRB NTPC CBT 1 Admit Card 2026 Released',
    slug: 'rrb-ntpc-cbt-1-admit-card-2026',
    excerpt:
        'Railway Recruitment Board (RRB) has released CBT 1 e-call letters for Non-Technical Popular Categories.',
    body:
        '## RRB NTPC E-Call Letter 2026\n\nCandidates appearing for RRB NTPC CBT 1 can now download their city intimation slip and admit card using their Registration Number and Date of Birth.',
    organization: 'Railway Recruitment Boards (RRB)',
    jobRole: 'NTPC Graduate & Undergraduate',
    vacancies: '11,558',
    qualification: '12th / Graduate',
    salary: 'Level 2 to Level 6',
    location: 'All India',
    importantDates: const [
      ImportantDateModel(
          id: '1', label: 'Admit Card Release Date', date: '10 Sep 2026'),
      ImportantDateModel(
          id: '2', label: 'CBT 1 Exam Dates', date: '20 Sep to 15 Oct 2026'),
    ],
    importantLinks: const [
      ImportantLinkModel(
          id: '1',
          title: 'Download Admit Card',
          url: 'https://rrbcdg.gov.in/admit-card',
          type: 'admit_card'),
      ImportantLinkModel(
          id: '2',
          title: 'Official RRB Notice',
          url: 'https://rrbcdg.gov.in/notice_cbt1.pdf',
          type: 'official_notification'),
    ],
    sourceOrg: 'Railway Recruitment Control Board',
    sourceUrl: 'https://rrbcdg.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-10T08:00:00.000Z',
    updatedAt: '2026-09-10T08:00:00.000Z',
    views: 19820,
    categoryIds: const ['admit-cards', 'railway'],
    tags: const ['rrb', 'ntpc', 'admit-card', 'railway'],
  ),
  ContentModel(
    id: 'upsc-civil-services-2026-result',
    contentType: 'result',
    title: 'UPSC Civil Services Prelims 2026 Result Declared',
    slug: 'upsc-civil-services-prelims-2026-result',
    excerpt:
        'Union Public Service Commission has announced the results for Civil Services Preliminary Examination 2026.',
    body:
        '## UPSC CSE Prelims 2026 Result\n\nThe Union Public Service Commission (UPSC) has published the PDF containing the roll numbers of candidates who qualified for the Civil Services (Mains) Examination 2026.',
    organization: 'Union Public Service Commission (UPSC)',
    jobRole: 'IAS, IPS, IFS & Central Group A Services',
    vacancies: '1,056',
    qualification: 'Graduate',
    salary: 'Level 10 onwards',
    location: 'New Delhi / All India',
    importantDates: const [
      ImportantDateModel(
          id: '1', label: 'Prelims Exam Date', date: '24 May 2026'),
      ImportantDateModel(
          id: '2', label: 'Result Declaration Date', date: '08 Sep 2026'),
      ImportantDateModel(
          id: '3', label: 'Mains Exam Starts', date: '18 Sep 2026'),
    ],
    importantLinks: const [
      ImportantLinkModel(
          id: '1',
          title: 'Download Result PDF',
          url: 'https://upsc.gov.in/results/cse_prelims_2026.pdf',
          type: 'result'),
      ImportantLinkModel(
          id: '2',
          title: 'Official UPSC Portal',
          url: 'https://upsc.gov.in',
          type: 'official_website'),
    ],
    sourceOrg: 'UPSC Dholpur House, New Delhi',
    sourceUrl: 'https://upsc.gov.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-08T15:00:00.000Z',
    updatedAt: '2026-09-08T15:00:00.000Z',
    views: 31200,
    categoryIds: const ['results'],
    tags: const ['upsc', 'cse', 'result', 'prelims', 'ias'],
  ),
  ContentModel(
    id: 'how-to-prepare-for-ssc-cgl-article',
    contentType: 'article',
    title:
        'How to Clear SSC CGL in First Attempt: Complete Strategy & Booklist',
    slug: 'how-to-clear-ssc-cgl-first-attempt-strategy',
    excerpt:
        'Detailed 6-month roadmap, daily schedule, section-wise strategy, and best books recommended by previous year toppers.',
    body:
        '## Comprehensive Preparation Guide for SSC CGL\n\nCracking SSC CGL requires a disciplined approach balancing accuracy and speed across four key pillars: Quantitative Aptitude, Reasoning, English Comprehension, and General Awareness.\n\n### 1. Mathematics / Quantitative Aptitude\nFocus on Arithmetic fundamentals first (Percentage, Ratio, Profit & Loss, Time & Work), followed by Advanced Maths (Algebra, Trigonometry, Geometry, Mensuration).\n\n### 2. English Comprehension\nDaily reading of newspaper editorials enhances comprehension and vocabulary.\n\n### 3. General Intelligence & Reasoning\nSolve 50 questions daily covering coding-decoding, series, syllogisms, and analogies.\n\n### 4. General Awareness\nDedicate 1 hour daily to current affairs and revise static GK notes systematically.',
    organization: 'Notify Jobs Editorial Desk',
    jobRole: 'Article / Guide',
    vacancies: '',
    qualification: '',
    salary: '',
    location: '',
    importantLinks: const [
      ImportantLinkModel(
          id: '1',
          title: 'Download Study Timetable PDF',
          url: 'https://notifyjobs.in/guides/ssc-roadmap.pdf',
          type: 'download_pdf'),
    ],
    sourceOrg: 'Notify Jobs Editorial',
    sourceUrl: 'https://notifyjobs.in',
    lastVerifiedAt: '12 Sep 2026',
    status: 'published',
    isPublished: true,
    publishedAt: '2026-09-02T12:00:00.000Z',
    updatedAt: '2026-09-02T12:00:00.000Z',
    views: 6420,
    categoryIds: const ['articles', 'ssc'],
    tags: const ['ssc', 'cgl', 'preparation', 'strategy', 'study-plan'],
  ),
];

/// Master Content Provider
final allContentProvider = Provider<List<ContentModel>>((ref) {
  return _initialContent;
});

/// Latest Government Jobs Provider
final latestJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'government_job').toList();
});

/// Popular This Week (Specification 86)
final popularThisWeekProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final copy = [...all];
  copy.sort((a, b) => b.views.compareTo(a.views));
  return copy.take(5).toList();
});

/// Andaman & Nicobar Jobs Provider (Specification 52)
final andamanJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) =>
          item.categoryIds.contains('andaman-nicobar') ||
          item.location.toLowerCase().contains('andaman') ||
          item.location.toLowerCase().contains('port blair'))
      .toList();
});

/// SSC Jobs Provider
final sscJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('ssc')).toList();
});

/// Railway Jobs Provider
final railwayJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('railway')).toList();
});

/// Banking Jobs Provider
final bankingJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('banking')).toList();
});

/// Police & Defence Jobs Provider
final policeJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) => item.categoryIds.contains('police-defence'))
      .toList();
});

/// Admit Cards Provider (Specification 55)
final admitCardsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'admit_card').toList();
});

/// Results Provider (Specification 54)
final resultsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'result').toList();
});

/// Answer Keys Provider (Specification 56)
final answerKeysProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'answer_key').toList();
});

/// Syllabus Provider (Specification 57)
final syllabusProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'syllabus').toList();
});

/// Articles Provider (Specification 58)
final articlesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'article').toList();
});

/// Content by ID or Slug Provider
final contentByIdProvider =
    Provider.family<ContentModel?, String>((ref, idOrSlug) {
  final all = ref.watch(allContentProvider);
  try {
    return all
        .firstWhere((item) => item.id == idOrSlug || item.slug == idOrSlug);
  } catch (_) {
    return null;
  }
});

/// Alias for detail screen lookup
final contentDetailProvider = contentByIdProvider;

/// Search content across title, organization, role and location
final searchContentProvider =
    Provider.family<List<ContentModel>, String>((ref, query) {
  final all = ref.watch(allContentProvider);
  if (query.trim().isEmpty) return all;
  final q = query.toLowerCase();
  return all.where((item) {
    return item.title.toLowerCase().contains(q) ||
        item.organization.toLowerCase().contains(q) ||
        (item.department?.toLowerCase().contains(q) ?? false) ||
        item.jobRole.toLowerCase().contains(q) ||
        item.location.toLowerCase().contains(q);
  }).toList();
});

/// Parameter class for category filtering with limit
class CategoryContentParams {
  final String category;
  final int limit;

  const CategoryContentParams({required this.category, this.limit = 10});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryContentParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          limit == other.limit;

  @override
  int get hashCode => category.hashCode ^ limit.hashCode;
}

/// Category Content Provider with limit
final categoryContentProvider =
    Provider.family<List<ContentModel>, CategoryContentParams>((ref, params) {
  final all = ref.watch(allContentProvider);
  final filtered = all
      .where((item) =>
          item.contentType == params.category ||
          item.categoryIds.contains(params.category))
      .take(params.limit)
      .toList();
  return filtered;
});
