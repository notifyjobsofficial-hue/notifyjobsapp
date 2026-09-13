import 'package:flutter_test/flutter_test.dart';
import 'package:notify_jobs/features/models/content_model.dart';
import 'package:notify_jobs/features/models/app_settings_model.dart';

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
}
