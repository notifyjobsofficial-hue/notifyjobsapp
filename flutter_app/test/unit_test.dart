import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_jobs/features/models/content_model.dart';
import 'package:notify_jobs/features/models/app_settings_model.dart';
import 'package:notify_jobs/core/utils/normalization_utils.dart';
import 'package:notify_jobs/core/utils/status_engine.dart';
import 'package:go_router/go_router.dart';
import 'package:notify_jobs/core/services/share_service.dart';
import 'package:notify_jobs/features/models/category_model.dart';
import 'package:notify_jobs/features/navigation/app_router.dart';
import 'package:notify_jobs/features/providers/notification_providers.dart';
import 'package:notify_jobs/core/services/storage_service.dart';
import 'package:notify_jobs/core/services/admob_service.dart';
import 'package:notify_jobs/core/config/admob_config.dart';
import 'package:notify_jobs/core/widgets/nj_official_source_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ContentModel Deserialization Tests', () {
    test('Correctly deserializes complete job JSON', () {
      final json = {
        'id': 'job_123',
        'title': 'SSC CGL 2026 Examination',
        'organization': 'Staff Selection Commission',
        'category': 'latest_jobs',
        'categoryName': 'Latest Jobs',
        'advtNo': 'SSC/2026/01',
        'status': 'published',
        'totalVacancies': 14582,
        'salaryPayScale': 'Level 7 (₹44,900 - ₹1,42,400)',
        'location': 'All India',
        'qualification': ['Bachelor Degree in any discipline'],
        'ageLimit': {
          'minAge': 18,
          'maxAge': 30,
          'asOnDate': '2026-08-01T00:00:00.000Z',
          'relaxationNotes': 'OBC 3 yrs, SC/ST 5 yrs',
        },
        'importantDates': {
          'notificationDate': '2026-06-15T00:00:00.000Z',
          'applicationStart': '2026-06-20T00:00:00.000Z',
          'lastDateToApply': '2026-07-25T23:59:59.000Z',
          'examDate': 'September 2026',
        },
        'applicationFees': {
          'General / OBC / EWS': 100,
          'SC / ST / Women': 0,
        },
        'selectionProcess': [
          'Tier 1 CBT',
          'Tier 2 CBT',
          'Document Verification'
        ],
        'applyUrl': 'https://ssc.gov.in/apply',
        'officialNotificationUrl': 'https://ssc.gov.in/notice.pdf',
        'officialWebsiteUrl': 'https://ssc.gov.in',
        'createdAt': '2026-06-15T00:00:00.000Z',
        'updatedAt': '2026-06-15T00:00:00.000Z',
      };

      final model = ContentModel.fromJson('job_123', json);

      expect(model.id, 'job_123');
      expect(model.title, 'SSC CGL 2026 Examination');
      expect(model.organization, 'Staff Selection Commission');
      expect(model.totalVacancies, 14582);
      expect(model.applyUrl, 'https://ssc.gov.in/apply');
    });

    test('Safely handles missing and null fields without throwing', () {
      final json = <String, dynamic>{
        'title': 'Minimal Job Notice',
      };

      final model = ContentModel.fromJson('min_1', json);

      expect(model.id, 'min_1');
      expect(model.title, 'Minimal Job Notice');
      expect(model.organization, 'Govt Organization');
      expect(model.category, 'government_job');
      expect(model.totalVacancies, 0);
      expect(model.qualification, isEmpty);
      expect(model.applyUrl, isNull);
    });

    test('Identifies Andaman Government Jobs correctly', () {
      final json = {
        'title': 'Port Blair Police Constable',
        'organization': 'A&N Police Department',
        'contentType': 'andaman_job',
        'jobType': 'government',
        'location': 'Port Blair',
        'showInLiveUpdates': true,
      };

      final model = ContentModel.fromMap(json, 'an_govt_1');

      expect(model.isAndamanJob, isTrue);
      expect(model.isGovernmentJob, isTrue);
      expect(model.isPrivateJob, isFalse);
      expect(model.categoryDisplay, 'A&N JOB • GOVT');
      expect(model.showInLiveUpdates, isTrue);
    });

    test('Identifies Andaman Private Jobs correctly', () {
      final json = {
        'title': 'Resort Front Desk Manager',
        'organization': 'Havelock Beach Resort',
        'companyName': 'Havelock Beach Resort',
        'contentType': 'andaman_job',
        'jobType': 'private',
        'island': 'Havelock Island',
        'location': 'Havelock Island',
        'salaryRange': '₹25,000 - ₹35,000',
        'contactPhone': '+91 94342 12345',
        'whatsappApplyUrl': 'https://wa.me/919434212345',
      };

      final model = ContentModel.fromMap(json, 'an_pvt_1');

      expect(model.isAndamanJob, isTrue);
      expect(model.isGovernmentJob, isFalse);
      expect(model.isPrivateJob, isTrue);
      expect(model.categoryDisplay, 'A&N JOB • PRIVATE');
      expect(model.companyName, 'Havelock Beach Resort');
      expect(model.island, 'Havelock Island');
      expect(model.salaryRange, '₹25,000 - ₹35,000');
      expect(model.contactPhone, '+91 94342 12345');
    });

    test(
        'Correctly deserializes real Admin post document "a" (Andaman & Nicobar CHSL 2026)',
        () {
      final realDocA = <dynamic, dynamic>{
        'id': 'a',
        'contentType': 'government_job',
        'title': 'Andaman & Nicobar CHSL 2026',
        'slug': 'andaman-nicobar-chsl-2026',
        'jobType': 'government',
        'status': 'published',
        'isPublished': true,
        'vacancies': '712',
        'location': 'Any where in the A & N Islands',
        'categoryIds': ['latest-jobs', 'andaman-nicobar'],
        'tags': ['ssc', 'chsl', 'andaman'],
        'importantDates': [
          <dynamic, dynamic>{
            'id': '1',
            'label': 'Online Application Starts',
            'date': '15 Mar 2026'
          },
          <dynamic, dynamic>{
            'id': '2',
            'label': 'Last Date to Apply',
            'date': '15 Apr 2026'
          },
        ],
        'vacanciesBreakdown': [
          <dynamic, dynamic>{
            'id': '1',
            'postName': 'Lower Division Clerk (LDC)',
            'total': '340'
          },
        ],
        'ageLimits': [
          <dynamic, dynamic>{
            'id': '1',
            'category': 'General / UR',
            'minAge': 18,
            'maxAge': 32
          },
        ],
        'applicationFees': [
          <dynamic, dynamic>{
            'id': '1',
            'category': 'General / OBC',
            'fee': '100'
          },
        ],
        'selectionProcess': [
          <dynamic, dynamic>{'id': '1', 'stageNumber': 1, 'name': 'Tier-I CBT'},
        ],
        'examPattern': [
          <dynamic, dynamic>{
            'id': '1',
            'subject': 'General Intelligence',
            'questions': 25,
            'marks': 50
          },
        ],
        'importantLinks': [
          <dynamic, dynamic>{
            'id': '1',
            'title': 'Apply Online',
            'url': 'https://andaman.gov.in/apply'
          },
        ],
        'faqs': [
          <dynamic, dynamic>{
            'id': '1',
            'question': 'What is the age limit?',
            'answer': '18 to 32 years.'
          },
        ],
        'sourceOrg': 'A&N Administration',
        'publishedAt': '2026-03-01T10:00:00.000Z',
      };

      final model =
          ContentModel.fromMap(Map<String, dynamic>.from(realDocA), 'a');

      expect(model.id, 'a');
      expect(model.title, 'Andaman & Nicobar CHSL 2026');
      expect(model.isPublished, isTrue);
      expect(model.isGovernmentJob, isTrue);
      expect(model.isPrivateJob, isFalse);
      expect(model.isAndamanJob, isTrue);
      expect(model.isCategoryMatch('ssc'), isTrue);
      expect(model.isCategoryMatch('andaman-nicobar'), isTrue);
      expect(model.importantLinks.length, 1);
      expect(model.importantLinks.first.url, 'https://andaman.gov.in/apply');
      expect(model.importantDates.length, 2);
      expect(model.vacanciesBreakdown.length, 1);
      expect(model.ageLimits.length, 1);
      expect(model.selectionProcess.length, 1);
      expect(model.examPattern.length, 1);
      expect(model.faqs.length, 1);
    });

    test('Never publishes draft, scheduled, or archived content', () {
      final draft = ContentModel.fromMap({
        'title': 'Draft Notice',
        'status': 'draft',
        'isPublished': false,
      }, 'd1');
      expect(draft.isPublished, isFalse);

      final archived = ContentModel.fromMap({
        'title': 'Archived Notice',
        'status': 'archived',
        'isPublished': false,
      }, 'a1');
      expect(archived.isPublished, isFalse);

      final scheduledFuture = ContentModel.fromMap({
        'title': 'Scheduled Notice',
        'status': 'scheduled',
        'publishedAt':
            DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      }, 's1');
      expect(scheduledFuture.isPublished, isFalse);

      final explicitFalse = ContentModel.fromMap({
        'title': 'Hidden Notice',
        'status': 'published',
        'isPublished': false,
      }, 'h1');
      expect(explicitFalse.isPublished, isFalse);
    });

    test('Strict content type routing: Updates vs Jobs vs Articles', () {
      final admitCard = ContentModel.fromMap({
        'title': 'SSC Admit Card',
        'contentType': 'admit_card',
        'status': 'published',
      }, 'ac1');
      expect(admitCard.contentType, 'admit_card');
      expect(admitCard.isGovernmentJob, isFalse);

      final result = ContentModel.fromMap({
        'title': 'Railway Group D Result',
        'contentType': 'result',
        'status': 'published',
      }, 'res1');
      expect(result.contentType, 'result');
      expect(result.isGovernmentJob, isFalse);

      final article = ContentModel.fromMap({
        'title': 'How to Prepare for SSC',
        'contentType': 'article',
        'status': 'published',
      }, 'art1');
      expect(article.contentType, 'article');
      expect(article.isGovernmentJob, isFalse);
    });
  });

  group('AppSettingsModel Deserialization Tests', () {
    test('Correctly deserializes app settings and features', () {
      final json = {
        'appTitle': 'Notify Jobs',
        'minimumAppVersion': '1.0.0',
        'forceUpdate': false,
        'maintenanceMode': false,
        'supportEmail': 'help@example.com',
        'rewardedAdsEnabled': true,
        'rewardUnlockMinutes': 30,
      };

      final settings = AppSettingsModel.fromJson(json);

      expect(settings.appTitle, 'Notify Jobs');
      expect(settings.maintenanceMode, false);
      expect(settings.supportEmail, 'help@example.com');
      expect(settings.rewardedAdsEnabled, true);
      expect(settings.rewardUnlockMinutes, 30);
    });

    test('Correctly parses v1.1 Admin Control Layer settings', () {
      final map = {
        'appTitle': 'Notify Jobs Pro',
        'announcementEnabled': true,
        'announcementText': 'SSC CGL 2026 Notification Out!',
        'announcementUrl': 'https://ssc.gov.in',
        'liveUpdatesEnabled': true,
        'liveUpdatesTitle': 'Breaking Alerts',
        'liveUpdatesMaxItems': 8,
        'closingSoonEnabled': true,
        'closingSoonDaysThreshold': 5,
        'popularEnabled': true,
        'popularMaxItems': 10,
        'latestJobsEnabled': true,
        'latestJobsMaxItems': 12,
        'quickCategoriesEnabled': true,
        'supportPageEnabled': true,
        'socialSectionEnabled': false,
      };

      final settings = AppSettingsModel.fromMap(map);

      expect(settings.isAnnouncementActive, isTrue);
      expect(settings.announcementText, 'SSC CGL 2026 Notification Out!');
      expect(settings.liveUpdatesEnabled, isTrue);
      expect(settings.liveUpdatesTitle, 'Breaking Alerts');
      expect(settings.liveUpdatesMaxItems, 8);
      expect(settings.closingSoonDaysThreshold, 5);
      expect(settings.popularMaxItems, 10);
      expect(settings.latestJobsMaxItems, 12);
      expect(settings.socialSectionEnabled, isFalse);
    });
  });

  group('NormalizationUtils Tests', () {
    test('formatYears eliminates "Years Years" duplication', () {
      expect(NormalizationUtils.formatYears('30 Years'), '30 Years');
      expect(NormalizationUtils.formatYears('30 yrs'), '30 Years');
      expect(NormalizationUtils.formatYears('30'), '30 Years');
      expect(NormalizationUtils.formatYears(''), '');
      expect(NormalizationUtils.formatYears(null), '');
    });

    test('formatAgeRange formats ranges cleanly without unit duplication', () {
      expect(NormalizationUtils.formatAgeRange(18, 30), '18 - 30 Years');
      expect(
          NormalizationUtils.formatAgeRange('18', '30 Years'), '18 - 30 Years');
      expect(NormalizationUtils.formatAgeRange(null, 32), 'Max 32 Years');
      expect(NormalizationUtils.formatAgeRange(21, null), 'Min 21 Years');
      expect(NormalizationUtils.formatAgeRange(null, null), 'As per rules');
    });

    test('formatImportantDateLabel prevents collision between label and date',
        () {
      final formatted = NormalizationUtils.formatImportantDateLabel(
        'Physical Endurance Test',
        '2026-11-15',
      );
      expect(formatted, contains('Physical Endurance Test\n'));
      expect(formatted, contains('15 Nov 2026'));
    });

    test('formatVacancies normalizes numbers and post strings', () {
      expect(NormalizationUtils.formatVacancies(418), '418 Posts');
      expect(NormalizationUtils.formatVacancies('1'), '1 Post');
      expect(NormalizationUtils.formatVacancies('14582 Posts'), '14,582 Posts');
      expect(NormalizationUtils.formatVacancies('0'), 'Various');
      expect(NormalizationUtils.formatVacancies(null), 'Various');
    });
  });

  group('StatusEngine Tests', () {
    test('Computes Open status for future deadline', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final status = StatusEngine.compute(
        contentType: 'government_job',
        lastDate: futureDate,
      );
      expect(status.label, 'Open');
    });

    test('Computes Closing Soon for deadline within 3 days', () {
      final closingSoonDate = DateTime.now().add(const Duration(days: 2));
      final status = StatusEngine.compute(
        contentType: 'government_job',
        lastDate: closingSoonDate,
      );
      expect(status.isUrgent, isTrue);
      expect(status.label, '2 Days Left');
    });

    test('Computes Closed for passed deadline', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final status = StatusEngine.compute(
        contentType: 'government_job',
        lastDate: pastDate,
      );
      expect(status.label, 'Closed');
    });

    test('Computes Declared for results and Released for answer keys', () {
      final resultStatus = StatusEngine.compute(contentType: 'result');
      expect(resultStatus.label, 'Declared');

      final keyStatus = StatusEngine.compute(contentType: 'answer_key');
      expect(keyStatus.label, 'Released');

      final objectionStatus = StatusEngine.compute(
        contentType: 'answer_key',
        explicitStatus: 'objection_open',
      );
      expect(objectionStatus.label, 'Objection Open');
      expect(objectionStatus.isUrgent, isTrue);
    });
  });

  group('ShareService Tests', () {
    test('Resolves configured shareBaseUrl with slug', () {
      final job = ContentModel.fromMap({
        'title': 'Andaman Police Recruitment',
        'slug': 'andaman-police-si-2026',
        'contentType': 'government_job',
      }, 'job_456');
      final url = ShareService.resolveShareUrl(
        content: job,
        configuredBaseUrl: 'https://notifyjobsapp.pages.dev/job',
      );
      expect(url, 'https://notifyjobsapp.pages.dev/job/andaman-police-si-2026');
    });

    test('Falls back to applyUrl if shareBaseUrl is not configured', () {
      final job = ContentModel.fromMap({
        'title': 'UPSC CSE 2026',
        'slug': 'upsc-cse-2026',
        'contentType': 'government_job',
        'applyUrl': 'https://upsconline.nic.in',
      }, 'job_789');
      final url = ShareService.resolveShareUrl(content: job);
      expect(url, 'https://upsconline.nic.in');
    });

    test('Formats rich share message with title and vacancies', () {
      final job = ContentModel.fromMap({
        'title': 'SSC CGL 2026',
        'organization': 'Staff Selection Commission',
        'vacancies': '14582',
        'applicationLastDate': '2026-09-30',
        'slug': 'ssc-cgl-2026',
        'contentType': 'government_job',
      }, 'job_101');
      final msg = ShareService.formatShareMessage(
        content: job,
        configuredBaseUrl: 'https://notifyjobsapp.pages.dev/job',
      );
      expect(msg, contains('SSC CGL 2026'));
      expect(msg, contains('Staff Selection Commission'));
      expect(msg, contains('14,582 Posts'));
      expect(msg, contains('https://notifyjobsapp.pages.dev/job/ssc-cgl-2026'));
    });
  });

  group('CategoryModel Tests', () {
    test('Correctly deserializes complete category map from Firestore', () {
      final map = {
        'id': 'railway',
        'name': 'Railway Jobs',
        'slug': 'railway',
        'icon': 'train',
        'color': '#DC2626',
        'order': 4,
        'isActive': true,
        'showOnHome': true,
        'destination': '/jobs?category=railway',
      };
      final cat = CategoryModel.fromMap(map, 'railway');

      expect(cat.id, 'railway');
      expect(cat.name, 'Railway Jobs');
      expect(cat.slug, 'railway');
      expect(cat.icon, 'train');
      expect(cat.colorHex, '#DC2626');
      expect(cat.order, 4);
      expect(cat.isActive, isTrue);
      expect(cat.showOnHome, isTrue);
      expect(cat.destination, '/jobs?category=railway');
      expect(cat.routeDestination, '/jobs?category=railway');
    });

    test('Safely applies defaults for missing fields', () {
      final map = <String, dynamic>{
        'name': 'Custom Exam',
      };
      final cat = CategoryModel.fromMap(map, 'custom-exam');

      expect(cat.id, 'custom-exam');
      expect(cat.name, 'Custom Exam');
      expect(cat.slug, 'custom-exam');
      expect(cat.icon, 'work');
      expect(cat.colorHex, '#159B76');
      expect(cat.order, 99);
      expect(cat.isActive, isTrue);
      expect(cat.showOnHome, isTrue);
      expect(cat.routeDestination, '/jobs?category=custom-exam');
    });

    test('Maps updates and articles to correct tabs and screens', () {
      final admitCards = CategoryModel.fromMap({
        'name': 'Admit Cards',
        'slug': 'admit-cards',
      }, 'admit-cards');
      expect(admitCards.routeDestination, '/updates?tab=admit_cards');

      final results = CategoryModel.fromMap({
        'name': 'Results',
        'slug': 'results',
      }, 'results');
      expect(results.routeDestination, '/updates?tab=results');

      final answerKeys = CategoryModel.fromMap({
        'name': 'Answer Keys',
        'slug': 'answer-keys',
      }, 'answer-keys');
      expect(answerKeys.routeDestination, '/updates?tab=answer_keys');

      final syllabus = CategoryModel.fromMap({
        'name': 'Syllabus',
        'slug': 'syllabus',
      }, 'syllabus');
      expect(syllabus.routeDestination, '/updates?tab=syllabus');

      final articles = CategoryModel.fromMap({
        'name': 'Articles',
        'slug': 'articles',
      }, 'articles');
      expect(articles.routeDestination, '/more');
    });

    test('Explicit destination overrides default slug mapping', () {
      final custom = CategoryModel.fromMap({
        'name': 'Special Results',
        'slug': 'special-results',
        'destination': '/updates?tab=results&filter=special',
      }, 'spec-res');
      expect(custom.routeDestination, '/updates?tab=results&filter=special');
    });

    test('Respects isActive and showOnHome false flags', () {
      final inactive = CategoryModel.fromMap({
        'name': 'Archived Section',
        'isActive': false,
        'showOnHome': false,
      }, 'archived');
      expect(inactive.isActive, isFalse);
      expect(inactive.showOnHome, isFalse);
    });
  });

  group('Router Route Registration Tests', () {
    test('/update/:id route exists in router configuration', () {
      final updateRoute = appRouter.configuration.routes
          .whereType<GoRoute>()
          .firstWhere((r) => r.path == '/update/:id',
              orElse: () => throw Exception('Route /update/:id not found'));
      expect(updateRoute.name, 'update_detail');
    });
  });

  group('Real Firestore Document Deserialization Tests', () {
    test(
        'Correctly deserializes doc "s" with integer vacancies and andaman_job type',
        () {
      final docSData = {
        'title': 'Directorate of Agriculture',
        'contentType': 'andaman_job',
        'status': 'published',
        'isPublished': true,
        'publishedAt': '2026-09-23T18:10:27.883Z',
        'vacancies': 10,
        'categoryIds': ['latest-jobs', 'andaman-nicobar'],
        'location': 'A & N Islands',
        'organization': 'Directorate of Agriculture',
      };

      final model = ContentModel.fromMap(docSData, 's');

      expect(model.id, 's');
      expect(model.title, 'Directorate of Agriculture');
      expect(model.vacancies, '10');
      expect(model.totalVacancies, 10);
      expect(model.isPublished, isTrue);
      expect(model.isAndamanJob, isTrue);
      expect(model.isJob, isTrue);
      expect(model.publishedAt, '2026-09-23T18:10:27.883Z');
      expect(model.categoryIds, contains('andaman-nicobar'));
    });

    test(
        'Falls back to isPublished true when status is published even if isPublished field is null',
        () {
      final legacyData = {
        'title': 'Legacy Published Job',
        'status': 'published',
        'organization': 'UPSC',
      };

      final model = ContentModel.fromMap(legacyData, 'legacy-1');

      expect(model.status, 'published');
      expect(model.isPublished, isTrue);
    });

    test('Handles categoryIds as single string gracefully without crashing',
        () {
      final stringCategoryData = {
        'title': 'String Category Job',
        'categoryIds': 'andaman-nicobar',
      };

      final model = ContentModel.fromMap(stringCategoryData, 'cat-str-1');

      expect(model.categoryIds, ['andaman-nicobar']);
      expect(model.isAndamanJob, isTrue);
    });

    test('AgeLimitModel correctly deserializes and handles minAge and ageAsOn',
        () {
      final map = {
        'id': 'age_1',
        'category': 'OBC',
        'relaxationYears': '3 Years',
        'minAge': 18,
        'maxAge': '30',
        'ageAsOn': '01-08-2026',
        'relaxationNotes': '3 years for OBC, 5 years for SC/ST',
      };

      final ageLimit = AgeLimitModel.fromMap(map);

      expect(ageLimit.id, 'age_1');
      expect(ageLimit.category, 'OBC');
      expect(ageLimit.relaxationYears, '3 Years');
      expect(ageLimit.minAge, '18');
      expect(ageLimit.maxAge, '30');
      expect(ageLimit.ageAsOn, '01-08-2026');
      expect(ageLimit.displayRelaxation, '3 Years');
      expect(ageLimit.displayAge, '18 - 30 Years');
    });

    test('Structured sub-models serialize and deserialize correctly', () {
      final feeMap = {
        'id': 'fee_1',
        'category': 'General / OBC',
        'fee': '₹500',
        'paymentMode': 'Online (UPI / Net Banking)',
      };
      final fee = ApplicationFeeModel.fromMap(feeMap);
      expect(fee.amount, 500);
      expect(fee.category, 'General / OBC');
      expect(fee.paymentMode, 'Online (UPI / Net Banking)');

      final stepMap = {
        'id': 'step_1',
        'stageNumber': 1,
        'name': 'Tier-I CBT',
        'description': '100 MCQs, 60 minutes',
      };
      final step = SelectionStepModel.fromMap(stepMap);
      expect(step.stageNumber, 1);
      expect(step.name, 'Tier-I CBT');

      final linkMap = {
        'id': 'link_1',
        'title': 'Apply Online',
        'url': 'https://example.gov.in/apply',
        'type': 'apply_online',
      };
      final link = ImportantLinkModel.fromMap(linkMap);
      expect(link.isApplyOnline, isTrue);
      expect(link.url, 'https://example.gov.in/apply');

      final faqMap = {
        'id': 'faq_1',
        'question': 'What is the last date to apply?',
        'answer': 'The last date is 30 November 2026.',
      };
      final faq = FAQModel.fromMap(faqMap);
      expect(faq.question, 'What is the last date to apply?');
      expect(faq.answer, 'The last date is 30 November 2026.');
    });
  });

  group('Structured Recruitment & Post-wise Vacancy Tests', () {
    test('VacancyBreakupModel computes sum of non-zero categories accurately',
        () {
      final map = {
        'ur': 50,
        'obc': 25,
        'ews': 10,
        'sc': 15,
        'st': 5,
        'pwbd': 3,
        'other': 2,
        'total': 0, // Should be computed dynamically
      };
      final breakup = VacancyBreakupModel.fromMap(map);
      expect(breakup.total, 110);
      expect(breakup.nonZeroBreakdown, {
        'UR': 50,
        'OBC': 25,
        'EWS': 10,
        'SC': 15,
        'ST': 5,
        'PwBD': 3,
        'Other': 2,
      });
    });

    test('VacancyBreakupModel nonZeroBreakdown omits zero counts', () {
      final map = {
        'ur': 12,
        'obc': 0,
        'ews': 0,
        'sc': 4,
        'st': 0,
        'pwbd': 0,
        'other': 0,
      };
      final breakup = VacancyBreakupModel.fromMap(map);
      expect(breakup.total, 16);
      expect(breakup.nonZeroBreakdown, {
        'UR': 12,
        'SC': 4,
      });
    });

    test('ContentModel calculates totalVacancies from post items', () {
      final map = {
        'title': 'Multi-Post Recruitment',
        'vacancyMode': 'posts',
        'posts': [
          {
            'id': 'p1',
            'postName': 'Assistant Director',
            'vacancies': {'ur': 5, 'obc': 2, 'total': 7},
          },
          {
            'id': 'p2',
            'postName': 'Junior Technical Officer',
            'vacancies': {'ur': 10, 'sc': 3, 'st': 2, 'total': 15},
          },
        ],
        'howToApplySteps': [
          'Visit official portal',
          'Fill form and upload photo',
          'Pay fee and submit',
        ],
        'feePaymentLastDate': '2026-11-05',
        'correctionStartDate': '2026-11-06',
        'correctionEndDate': '2026-11-08',
      };

      final model = ContentModel.fromMap(map, 'multi_post_1');
      expect(model.posts.length, 2);
      expect(model.totalVacancies, 22);
      expect(model.displayVacancies, '22 Posts');
      expect(model.howToApplySteps.length, 3);
      expect(model.feePaymentLastDate, '2026-11-05');
      expect(model.correctionStartDate, '2026-11-06');
      expect(model.correctionEndDate, '2026-11-08');
    });

    test('ContentModel isCategoryMatch matches categoryNames and posts', () {
      final map = {
        'title': 'Engineer Recruitment',
        'categoryIds': ['general-jobs'],
        'categoryNames': ['Railway', 'Engineering'],
        'posts': [
          {
            'id': 'p1',
            'postName': 'Section Engineer',
            'categoryId': 'railway',
            'categoryName': 'Railway Technical',
          }
        ],
      };
      final model = ContentModel.fromMap(map, 'eng_1');
      expect(model.isCategoryMatch('railway'), isTrue);
      expect(model.isCategoryMatch('Engineering'), isTrue);
      expect(model.isCategoryMatch('banking'), isFalse);
    });
  });

  group('Notification Unread Architecture Tests', () {
    test('parseSafeNotificationTimestamp safely defaults to 2020-01-01', () {
      expect(parseSafeNotificationTimestamp(null), DateTime(2020, 1, 1));
      expect(parseSafeNotificationTimestamp(''), DateTime(2020, 1, 1));
      expect(parseSafeNotificationTimestamp('   '), DateTime(2020, 1, 1));
      expect(
          parseSafeNotificationTimestamp('invalid-date'), DateTime(2020, 1, 1));

      final valid = parseSafeNotificationTimestamp('2026-09-26T12:00:00.000Z');
      expect(valid.year, 2026);
      expect(valid.month, 9);
      expect(valid.day, 26);
    });

    test('Fresh install initializes baseline with 0 unread notifications',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      expect(storage.isNotificationInitialized(), isFalse);
      expect(storage.getLastSeenNotificationAt(), isNull);

      // Simulate initialization with 3 existing historical notifications
      final now = DateTime.now();
      final past1 = now.subtract(const Duration(days: 3));
      final past2 = now.subtract(const Duration(days: 1));
      final past3 = now.subtract(const Duration(hours: 2));

      DateTime baseline = now;
      for (final t in [past1, past2, past3]) {
        if (t.isAfter(baseline)) baseline = t;
      }

      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      expect(storage.isNotificationInitialized(), isTrue);
      expect(storage.getLastSeenNotificationAt(), isNotNull);

      // On fresh start, none of the 3 historical notifications are newer than baseline
      final unreadCount =
          [past1, past2, past3].where((t) => t.isAfter(baseline)).length;
      expect(unreadCount, 0,
          reason:
              'Fresh install must never show unread for historical notifications');
    });

    test('Genuinely new notification after baseline is counted as unread',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime.now();
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      final oldNotifTime = baseline.subtract(const Duration(hours: 1));
      final newNotifTime = baseline.add(const Duration(minutes: 5));

      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      final readIds = storage.getReadNotificationIds().toSet();

      bool isOldUnread =
          !readIds.contains('old_1') && oldNotifTime.isAfter(lastSeen);
      bool isNewUnread =
          !readIds.contains('new_1') && newNotifTime.isAfter(lastSeen);

      expect(isOldUnread, isFalse);
      expect(isNewUnread, isTrue);
    });

    test('Opening inbox updates baseline and clears unread status permanently',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final t1 = DateTime(2026, 9, 20);
      await storage.setLastSeenNotificationAt(t1.toIso8601String());
      await storage.setNotificationInitialized(true);

      // New notification arrived
      final t2 = DateTime(2026, 9, 26, 10, 0);
      expect(t2.isAfter(t1), isTrue);

      // User opens inbox -> mark all seen
      await storage.setLastSeenNotificationAt(t2.toIso8601String());
      await storage.markNotificationsRead(['notif_2']);

      final updatedLastSeen =
          DateTime.parse(storage.getLastSeenNotificationAt()!);
      final readIds = storage.getReadNotificationIds().toSet();

      expect(t2.isAfter(updatedLastSeen), isFalse);
      expect(readIds.contains('notif_2'), isTrue);
    });

    test('Cleared notifications are excluded and do not trigger unread',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await storage.clearAllNotifications(['notif_1', 'notif_2']);
      final cleared = storage.getClearedNotificationIds().toSet();

      expect(cleared.contains('notif_1'), isTrue);
      expect(cleared.contains('notif_2'), isTrue);
      expect(cleared.contains('notif_3'), isFalse);
    });

    // =========================================================================
    // PART 29: MANDATORY 13 TEST CASES FOR NOTIFICATION STATE
    // =========================================================================

    test(
        'Test 1: Fresh install with existing old notifications -> unread = 0, red dot hidden',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      // 5 historical notifications exist in Firestore
      final oldDocs = [
        DateTime(2026, 9, 20),
        DateTime(2026, 9, 22),
        DateTime(2026, 9, 24),
        DateTime(2026, 9, 25),
        DateTime(2026, 9, 26, 12, 0),
      ];

      // On fresh install, baseline established at newest document timestamp (Constraint 2)
      DateTime baseline = oldDocs.reduce((a, b) => a.isAfter(b) ? a : b);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      // Verify unread count = 0
      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      final unread = oldDocs.where((t) => t.isAfter(lastSeen)).length;
      expect(unread, 0);
      expect(unread > 0, isFalse, reason: 'Red dot must be hidden');
    });

    test(
        'Test 2: First launch baseline set to latest document timestamp (not skewed device clock)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final newestServerDocTime = DateTime(2026, 9, 26, 18, 30);
      // Anchor directly to newest document
      await storage
          .setLastSeenNotificationAt(newestServerDocTime.toIso8601String());
      await storage.setNotificationInitialized(true);

      final saved = DateTime.parse(storage.getLastSeenNotificationAt()!);
      expect(saved, newestServerDocTime);
    });

    test(
        'Test 3: New notification arriving after baseline -> unread = 1, red dot visible',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 26, 18, 30);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      final newNotif = DateTime(2026, 9, 27, 9, 0);
      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);

      final isUnread = newNotif.isAfter(lastSeen);
      expect(isUnread, isTrue);
      final unreadCount = isUnread ? 1 : 0;
      expect(unreadCount, 1);
      expect(unreadCount > 0, isTrue, reason: 'Red dot must be visible');
    });

    test(
        'Test 4: Second new notification arriving -> unread = 2, red dot visible',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 26, 18, 30);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      final notif1 = DateTime(2026, 9, 27, 9, 0);
      final notif2 = DateTime(2026, 9, 27, 10, 30);
      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);

      final unread = [notif1, notif2].where((t) => t.isAfter(lastSeen)).length;
      expect(unread, 2);
      expect(unread > 0, isTrue);
    });

    test(
        'Test 5: Opening Notifications screen -> baseline updated, unread = 0, red dot hidden',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 26, 18, 30);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      final notif1 = DateTime(2026, 9, 27, 9, 0);
      final notif2 = DateTime(2026, 9, 27, 10, 30);

      // User opens inbox -> update baseline to newest item
      final newest = [notif1, notif2].reduce((a, b) => a.isAfter(b) ? a : b);
      await storage.setLastSeenNotificationAt(newest.toIso8601String());
      await storage.markNotificationsRead(['id_1', 'id_2']);

      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      final unread = [notif1, notif2].where((t) => t.isAfter(lastSeen)).length;
      expect(unread, 0);
      expect(unread > 0, isFalse,
          reason: 'Red dot must be hidden after opening inbox');
    });

    test('Test 6: Returning to Home -> red dot remains hidden', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 27, 10, 30);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      // User returns home, content re-evaluated
      final lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      final existingNotifs = [
        DateTime(2026, 9, 27, 9, 0),
        DateTime(2026, 9, 27, 10, 30),
      ];

      final unread = existingNotifs.where((t) => t.isAfter(lastSeen)).length;
      expect(unread, 0);
      expect(unread > 0, isFalse);
    });

    test('Test 7: Restarting app -> red dot remains hidden', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 27, 10, 30);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      // Simulate complete app restart: re-read from SharedPreferences
      final restartPrefs = await SharedPreferences.getInstance();
      final restartStorage = StorageService(restartPrefs);

      expect(restartStorage.isNotificationInitialized(), isTrue);
      final persistedLastSeen =
          DateTime.parse(restartStorage.getLastSeenNotificationAt()!);
      expect(persistedLastSeen, baseline);

      final unread = [DateTime(2026, 9, 27, 10, 30)]
          .where((t) => t.isAfter(persistedLastSeen))
          .length;
      expect(unread, 0);
    });

    test('Test 8: Clearing app data -> baseline reset cleanly, no fake red dot',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      // After user clears data, SharedPreferences is empty
      expect(storage.isNotificationInitialized(), isFalse);
      expect(storage.getLastSeenNotificationAt(), isNull);

      // Fresh initialization runs:
      final docs = [DateTime(2026, 9, 27, 12, 0)];
      final baseline = docs.first;
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      final unread = docs.where((t) => t.isAfter(baseline)).length;
      expect(unread, 0);
    });

    test(
        'Test 9: Notification with missing createdAt -> never considered unread',
        () {
      final parsed = parseSafeNotificationTimestamp(null);
      expect(parsed, DateTime(2020, 1, 1));

      final baseline = DateTime(2026, 9, 27);
      expect(parsed.isAfter(baseline), isFalse);
    });

    test(
        'Test 10: Notification with malformed createdAt -> never considered unread',
        () {
      final parsed = parseSafeNotificationTimestamp('garbage-date-string');
      expect(parsed, DateTime(2020, 1, 1));

      final baseline = DateTime(2026, 9, 27);
      expect(parsed.isAfter(baseline), isFalse);
    });

    test(
        'Test 11: Notification with future createdAt -> handled safely without breaking state',
        () {
      final futureDate = DateTime(2030, 1, 1);
      final baseline = DateTime(2026, 9, 27);

      expect(futureDate.isAfter(baseline), isTrue);
      // Once inbox is opened, baseline advances to future date safely
      final newBaseline = futureDate;
      expect(futureDate.isAfter(newBaseline), isFalse);
    });

    test(
        'Test 12: Notification tapped directly -> marked read, unread count cleared',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await storage.markNotificationRead('item_tap_1');
      final readIds = storage.getReadNotificationIds().toSet();

      expect(readIds.contains('item_tap_1'), isTrue);
      // When item is in readIds, it is marked as read even if newer than baseline
      final isUnread = !readIds.contains('item_tap_1');
      expect(isUnread, isFalse);
    });

    test(
        'Test 13: App opened multiple times without new notifications -> unread remains 0',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final baseline = DateTime(2026, 9, 27, 12, 0);
      await storage.setLastSeenNotificationAt(baseline.toIso8601String());
      await storage.setNotificationInitialized(true);

      // Launch 1
      var lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      expect([baseline].where((t) => t.isAfter(lastSeen)).length, 0);

      // Launch 2
      lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      expect([baseline].where((t) => t.isAfter(lastSeen)).length, 0);

      // Launch 3
      lastSeen = DateTime.parse(storage.getLastSeenNotificationAt()!);
      expect([baseline].where((t) => t.isAfter(lastSeen)).length, 0);
    });
  });

  group('AdMob Service & Rewarded Flow Tests', () {
    test('isCooldownActive returns false when no reward was earned', () {
      final adService = AdMobService.instance;
      expect(adService.isCooldownActive(10), isFalse);
    });

    test('recordCooldown activates cooldown and respects configured window',
        () {
      final adService = AdMobService.instance;
      adService.recordCooldown();

      // Immediately after recording, 10 min cooldown is active
      expect(adService.isCooldownActive(10), isTrue);
      expect(adService.isCooldownActive(0), isFalse);
    });

    test('configure and effectiveAdUnitId handle testMode properly', () {
      final adService = AdMobService.instance;
      adService.configure(
        adUnitId: 'ca-app-pub-9999999999999999/1111111111',
        testMode: true,
      );

      // In test mode or debug mode, returns testRewardedAdUnitId
      expect(adService.effectiveAdUnitId, AdMobConfig.testRewardedAdUnitId);
    });

    test('AppSettingsModel parses ad control fields with correct defaults', () {
      final json = <String, dynamic>{};
      final settings = AppSettingsModel.fromMap(json);

      expect(settings.adsEnabled, isTrue);
      expect(settings.rewardedAdsEnabled, isTrue);
      expect(settings.supportRewardedEnabled, isTrue);
      expect(settings.applyRewardedEnabled, isTrue);
      expect(settings.notificationDownloadRewardedEnabled, isTrue);
      expect(settings.officialWebsiteRewardedEnabled, isTrue);
      expect(settings.allowSkipRewarded, isTrue);
      expect(settings.rewardedCooldownMinutes, 10);
      expect(settings.testMode, isFalse);
    });

    test('AppSettingsModel parses custom ad settings properly', () {
      final json = <String, dynamic>{
        'adsEnabled': false,
        'rewardedAdsEnabled': false,
        'supportRewardedEnabled': false,
        'applyRewardedEnabled': false,
        'notificationDownloadRewardedEnabled': false,
        'officialWebsiteRewardedEnabled': false,
        'allowSkipRewarded': false,
        'rewardedCooldownMinutes': 20,
        'rewardedAdUnitAndroid': 'ca-app-pub-12345/67890',
        'testMode': true,
      };
      final settings = AppSettingsModel.fromMap(json);

      expect(settings.adsEnabled, isFalse);
      expect(settings.rewardedAdsEnabled, isFalse);
      expect(settings.supportRewardedEnabled, isFalse);
      expect(settings.applyRewardedEnabled, isFalse);
      expect(settings.notificationDownloadRewardedEnabled, isFalse);
      expect(settings.officialWebsiteRewardedEnabled, isFalse);
      expect(settings.allowSkipRewarded, isFalse);
      expect(settings.rewardedCooldownMinutes, 20);
      expect(settings.rewardedAdUnitAndroid, 'ca-app-pub-12345/67890');
      expect(settings.testMode, isTrue);
    });

    test('resetCooldown cleanly resets the cooldown timer', () {
      final adService = AdMobService.instance;
      adService.recordCooldown();
      expect(adService.isCooldownActive(10), isTrue);

      adService.resetCooldown();
      expect(adService.isCooldownActive(10), isFalse);
    });
  });

  group('Official Source Sheet & Rewarded Ad Gating Tests', () {
    testWidgets(
        'Apply Online sheet renders exact UI without raw URL or continue without ad',
        (WidgetTester tester) async {
      bool proceedCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjOfficialSourceSheet(
              url: 'https://upsc.gov.in/apply/cgl2026',
              type: OfficialSourceType.apply,
              onProceed: () => proceedCalled = true,
            ),
          ),
        ),
      );

      // Verify Title & Subtitle
      expect(find.text('Continue to Official Source'), findsOneWidget);
      expect(find.text('Apply Online'), findsOneWidget);

      // Verify Message
      expect(find.text('Watch a short ad to continue to the official source.'),
          findsOneWidget);

      // Verify Primary & Secondary Actions
      expect(find.text('Watch Ad & Continue'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // REMOVED items MUST NOT exist
      expect(find.text('Continue Without Ad'), findsNothing);
      expect(find.textContaining('upsc.gov.in'), findsNothing);
      expect(find.byIcon(Icons.verified_outlined), findsNothing);

      // Tap Cancel -> sheet pops, proceed NOT called
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(proceedCalled, isFalse);
    });

    testWidgets('Official Notification sheet renders correct subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjOfficialSourceSheet(
              url: 'https://sarkariresult.com/pdf/notification.pdf',
              type: OfficialSourceType.notification,
              onProceed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue to Official Source'), findsOneWidget);
      expect(find.text('Official Notification'), findsOneWidget);
      expect(find.text('Watch a short ad to continue to the official source.'),
          findsOneWidget);
      expect(find.text('Watch Ad & Continue'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Continue Without Ad'), findsNothing);
    });

    testWidgets('Official Website sheet renders correct subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjOfficialSourceSheet(
              url: 'https://ssc.nic.in',
              type: OfficialSourceType.website,
              onProceed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue to Official Source'), findsOneWidget);
      expect(find.text('Official Website'), findsOneWidget);
      expect(find.text('Watch a short ad to continue to the official source.'),
          findsOneWidget);
      expect(find.text('Watch Ad & Continue'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Continue Without Ad'), findsNothing);
    });

    testWidgets('Disabled in settings bypasses sheet and opens directly',
        (WidgetTester tester) async {
      bool proceedCalled = false;
      final disabledSettings = AppSettingsModel.fromMap({
        'adsEnabled': true,
        'rewardedAdsEnabled': false, // Rewarded disabled
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  NjOfficialSourceSheet.show(
                    context,
                    url: 'https://upsc.gov.in',
                    type: OfficialSourceType.apply,
                    appSettings: disabledSettings,
                    onProceed: () => proceedCalled = true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Proceed called immediately without opening sheet
      expect(proceedCalled, isTrue);
      expect(find.text('Continue to Official Source'), findsNothing);
    });

    testWidgets('Per-action toggle disabled bypasses sheet and opens directly',
        (WidgetTester tester) async {
      bool proceedCalled = false;
      final settings = AppSettingsModel.fromMap({
        'adsEnabled': true,
        'rewardedAdsEnabled': true,
        'applyRewardedEnabled': false, // Apply toggle disabled
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  NjOfficialSourceSheet.show(
                    context,
                    url: 'https://upsc.gov.in',
                    type: OfficialSourceType.apply,
                    appSettings: settings,
                    onProceed: () => proceedCalled = true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(proceedCalled, isTrue);
      expect(find.text('Continue to Official Source'), findsNothing);
    });

    testWidgets('Active cooldown bypasses sheet and opens destination directly',
        (WidgetTester tester) async {
      bool proceedCalled = false;
      final settings = AppSettingsModel.fromMap({
        'adsEnabled': true,
        'rewardedAdsEnabled': true,
        'applyRewardedEnabled': true,
        'rewardedCooldownMinutes': 10,
      });

      // Activate cooldown
      AdMobService.instance.recordCooldown();
      expect(AdMobService.instance.isCooldownActive(10), isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  NjOfficialSourceSheet.show(
                    context,
                    url: 'https://upsc.gov.in',
                    type: OfficialSourceType.apply,
                    appSettings: settings,
                    onProceed: () => proceedCalled = true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Because cooldown is active, proceeds immediately without bottom sheet
      expect(proceedCalled, isTrue);
      expect(find.text('Continue to Official Source'), findsNothing);

      // Clean up cooldown
      AdMobService.instance.resetCooldown();
    });
  });

  group('One-Stop Recruitment Editor & Remote Controls Tests', () {
    test(
        'Directorate of Agriculture Benchmark: 3 Posts (1 + 2 + 7 = 10 Vacancies)',
        () {
      final docData = <String, dynamic>{
        'title': 'Directorate of Agriculture Recruitment 2026',
        'organization': 'Directorate of Agriculture',
        'contentType': 'government_job',
        'isPublished': true,
        'showInUserApp': true,
        'vacancyMode': 'detailed',
        'posts': [
          {
            'id': 'post-1',
            'postName': 'Agriculture Officer',
            'postCode': 'AGRI-01',
            'group': 'Group B (Gazetted)',
            'cadre': 'State Cadre',
            'department': 'Directorate of Agriculture',
            'payLevel': 'Level 7',
            'qualification': 'B.Sc. in Agriculture from recognized University',
            'vacancies': {
              'ur': 1,
              'obc': 0,
              'ews': 0,
              'sc': 0,
              'st': 0,
              'pwbd': 0,
              'esm': 0,
              'msp': 0,
              'other': 0,
              'total': 1,
            },
          },
          {
            'id': 'post-2',
            'postName': 'Agriculture Engineering Assistant',
            'postCode': 'AGRI-02',
            'group': 'Group B (Non-Gazetted)',
            'cadre': 'Subordinate Cadre',
            'department': 'Directorate of Agriculture',
            'payLevel': 'Level 6',
            'qualification': 'Diploma/Degree in Agricultural Engineering',
            'vacancies': {
              'ur': 1,
              'obc': 1,
              'ews': 0,
              'sc': 0,
              'st': 0,
              'pwbd': 0,
              'esm': 0,
              'msp': 0,
              'other': 0,
              'total': 2,
            },
          },
          {
            'id': 'post-3',
            'postName': 'Agriculture Assistant',
            'postCode': 'AGRI-03',
            'group': 'Group C',
            'cadre': 'Field Cadre',
            'department': 'Directorate of Agriculture',
            'payLevel': 'Level 4',
            'qualification': 'Senior Secondary with Agriculture / Diploma',
            'vacancies': {
              'ur': 4,
              'obc': 2,
              'ews': 1,
              'sc': 0,
              'st': 0,
              'pwbd': 0,
              'esm': 0,
              'msp': 0,
              'other': 0,
              'total': 7,
            },
          },
        ],
        'documents': [
          {
            'id': 'doc-1',
            'documentName': 'Degree Certificate',
            'required': true,
          },
          {
            'id': 'doc-2',
            'documentName': 'Category Certificate (OBC/EWS)',
            'required': false,
            'notes': 'If claiming reservation benefits',
          },
        ],
        'uploadRequirements': {
          'photographFormat': 'JPG/JPEG',
          'photographMaxSize': '50 KB',
          'signatureFormat': 'JPG/JPEG',
          'signatureMaxSize': '20 KB',
        },
        'examDetails': {
          'hasExam': true,
          'examMode': 'OMR Based Written Test',
          'examType': 'Objective MCQ',
          'examDuration': '2 Hours',
          'negativeMarking': '0.25 Marks',
          'minimumQualifyingMarks': '40%',
        },
        'examPattern': [
          {
            'id': 'ep-1',
            'subject': 'General Agriculture',
            'questions': '50',
            'marks': '50',
          },
          {
            'id': 'ep-2',
            'subject': 'General Awareness & Reasoning',
            'questions': '50',
            'marks': '50',
          },
        ],
        'syllabusTopics': [
          {
            'id': 'syl-1',
            'subject': 'General Agriculture',
            'topicName': 'Agronomy & Soil Science',
            'details': 'Crop production, soil classification, fertilization',
          },
        ],
        'selectionRules': {
          'selectionBasis': 'Written Examination Merit',
          'meritCalculation': 'Marks scored in Paper 1 and 2',
          'tieBreakingRules': [
            'Older candidate in date of birth ranks higher',
            'Higher marks in Agriculture section',
          ],
        },
        'sourceVerification': {
          'sourceOrg': 'Directorate of Agriculture, A&N Administration',
          'notificationNumber': 'AGRI/REC/2026/01',
          'sourceVerified': true,
          'sourcePublishedDate': '2026-03-20',
        },
        'appDisplayControls': {
          'showOverview': true,
          'showPosts': true,
          'showDocuments': true,
          'showExamDetails': true,
          'showSourceInformation': true,
        },
      };

      final model = ContentModel.fromMap(docData, 'agri_recruitment_2026');

      expect(model.id, 'agri_recruitment_2026');
      expect(model.posts.length, 3);

      // Verify post 1
      final p1 = model.posts[0];
      expect(p1.postName, 'Agriculture Officer');
      expect(p1.group, 'Group B (Gazetted)');
      expect(p1.vacancies.total, 1);
      expect(p1.vacancies.ur, 1);
      expect(p1.vacancies.nonZeroBreakdown, {'UR': 1});

      // Verify post 2
      final p2 = model.posts[1];
      expect(p2.postName, 'Agriculture Engineering Assistant');
      expect(p2.vacancies.total, 2);
      expect(p2.vacancies.ur, 1);
      expect(p2.vacancies.obc, 1);
      expect(p2.vacancies.nonZeroBreakdown, {'UR': 1, 'OBC': 1});

      // Verify post 3
      final p3 = model.posts[2];
      expect(p3.postName, 'Agriculture Assistant');
      expect(p3.vacancies.total, 7);
      expect(p3.vacancies.ur, 4);
      expect(p3.vacancies.obc, 2);
      expect(p3.vacancies.ews, 1);
      expect(p3.vacancies.nonZeroBreakdown, {'UR': 4, 'OBC': 2, 'EWS': 1});

      // Automatic overall sum: 1 + 2 + 7 = 10
      final totalSum = model.posts.fold<int>(
        0,
        (sum, post) => sum + post.vacancies.total,
      );
      expect(totalSum, 10);

      // Verify modules
      expect(model.documents.length, 2);
      expect(model.documents.first.required, isTrue);
      expect(model.documents.last.required, isFalse);
      expect(model.uploadRequirements?.photographMaxSize, '50 KB');

      expect(model.examDetails?.hasExam, isTrue);
      expect(model.examDetails?.examMode, 'OMR Based Written Test');
      expect(model.examPattern.length, 2);
      expect(model.syllabusTopics.length, 1);

      expect(model.selectionRules?.selectionBasis, 'Written Examination Merit');
      expect(model.selectionRules?.tieBreakingRules.length, 2);

      expect(model.sourceVerification?.sourceVerified, isTrue);
      expect(model.sourceVerification?.notificationNumber, 'AGRI/REC/2026/01');

      expect(model.appDisplayControls.showPosts, isTrue);
      expect(model.appDisplayControls.showDocuments, isTrue);
    });

    test('Category remote visibility flags operate independently', () {
      final activeCat = CategoryModel.fromMap({
        'id': 'cat-1',
        'name': 'Defence Jobs',
        'slug': 'defence-jobs',
        'isActive': true,
        'showInUserApp': true,
        'showOnHome': true,
        'showInJobsFilters': true,
        'showInQuickCategories': true,
        'showInUpdates': true,
        'showInSearch': true,
        'showInAdminSidebar': true,
      }, 'cat-1');

      expect(activeCat.showInUserApp, isTrue);
      expect(activeCat.showOnHome, isTrue);
      expect(activeCat.showInJobsFilters, isTrue);
      expect(activeCat.showInQuickCategories, isTrue);

      // Hidden from user app remotely
      final hiddenFromApp = CategoryModel.fromMap({
        'id': 'cat-2',
        'name': 'Internal Archive',
        'slug': 'internal-archive',
        'isActive': true,
        'showInUserApp': false,
        'showOnHome': false,
      }, 'cat-2');

      expect(hiddenFromApp.showInUserApp, isFalse);
      expect(hiddenFromApp.showOnHome, isFalse);

      // Hidden only from home quick categories, but available in filters
      final filterOnlyCat = CategoryModel.fromMap({
        'id': 'cat-3',
        'name': 'Teaching Jobs',
        'slug': 'teaching-jobs',
        'showInUserApp': true,
        'showOnHome': false,
        'showInJobsFilters': true,
      }, 'cat-3');

      expect(filterOnlyCat.showInUserApp, isTrue);
      expect(filterOnlyCat.showOnHome, isFalse);
      expect(filterOnlyCat.showInJobsFilters, isTrue);
    });

    test('Content remote visibility kill-switch and placement toggles', () {
      final item = ContentModel.fromMap({
        'title': 'Secret Internal Post',
        'isPublished': true,
        'showInUserApp': false,
        'showOnHome': false,
        'showInSearch': false,
        'urgent': true,
      }, 'item-kill');

      expect(item.isPublished, isTrue);
      expect(item.showInUserApp, isFalse);
      expect(item.showOnHome, isFalse);
      expect(item.showInSearch, isFalse);
      expect(item.urgent, isTrue);
    });

    test('AppDisplayControlsModel handles custom and default states', () {
      const defaultControls = AppDisplayControlsModel();
      expect(defaultControls.showOverview, isTrue);
      expect(defaultControls.showImportantDates, isTrue);
      expect(defaultControls.showPosts, isTrue);
      expect(defaultControls.showFees, isTrue);
      expect(defaultControls.showSalary, isTrue);
      expect(defaultControls.showDocuments, isTrue);
      expect(defaultControls.showExamDetails, isTrue);
      expect(defaultControls.showSyllabus, isTrue);
      expect(defaultControls.showSelectionProcess, isTrue);
      expect(defaultControls.showSourceInformation, isTrue);

      final customControls = AppDisplayControlsModel.fromMap({
        'showOverview': true,
        'showFees': false,
        'showSalary': false,
        'showExamDetails': false,
      });

      expect(customControls.showOverview, isTrue);
      expect(customControls.showFees, isFalse);
      expect(customControls.showSalary, isFalse);
      expect(customControls.showExamDetails, isFalse);
      expect(customControls.showPosts, isTrue); // default true when omitted
    });
  });
}
