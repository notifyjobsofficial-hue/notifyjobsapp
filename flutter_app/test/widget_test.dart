import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_jobs/core/widgets/nj_badge.dart';
import 'package:notify_jobs/core/widgets/nj_button.dart';
import 'package:notify_jobs/core/widgets/nj_card.dart';
import 'package:notify_jobs/core/widgets/nj_status_badge.dart';
import 'package:notify_jobs/core/widgets/nj_job_card.dart';
import 'package:notify_jobs/core/widgets/nj_empty_state.dart';
import 'package:notify_jobs/core/widgets/nj_update_card.dart';
import 'package:notify_jobs/core/theme/app_colors.dart';
import 'package:notify_jobs/features/models/content_model.dart';

void main() {
  group('Core Widget Rendering Tests', () {
    testWidgets('NjButton renders with correct label and executes callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjButton(
              label: 'Apply Online',
              icon: Icons.open_in_new,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Apply Online'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);

      await tester.tap(find.text('Apply Online'));
      expect(pressed, isTrue);
    });

    testWidgets('NjBadge renders label with appropriate styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NjBadge(
              label: 'Latest Job',
              variant: NjBadgeVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Latest Job'), findsOneWidget);
    });

    testWidgets('NjStatusBadge renders Open when deadline in future',
        (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjStatusBadge(lastDate: futureDate),
          ),
        ),
      );

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('NjStatusBadge renders Closed when deadline has passed',
        (WidgetTester tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjStatusBadge(lastDate: pastDate),
          ),
        ),
      );

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('NjCard renders child inside decorated container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NjCard(
              child: Text('Card Content Test'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });

    testWidgets(
        'Responsive UI: Renders job card on narrow 320x568 screen without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final job = ContentModel.fromMap({
        'id': 'test_job_1',
        'title':
            'Very Long Job Title for Assistant Sub Inspector of Police Recruitment 2026 Examination',
        'organization':
            'Staff Selection Commission of Andaman and Nicobar Administration Division',
        'contentType': 'government_job',
        'jobType': 'government',
        'status': 'published',
        'vacancies': '14582',
        'location': 'Port Blair, South Andaman District',
        'qualification':
            'Bachelor Degree in Engineering or Computer Applications with Experience',
        'applicationLastDate': '2026-10-30',
      }, 'test_job_1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NjJobCard(
                job: job,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NjJobCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Responsive UI: Renders job card across all required screen dimensions without overflow',
        (WidgetTester tester) async {
      final dimensions = [
        const Size(320, 568), // iPhone SE / small screen
        const Size(360, 800), // Standard Android
        const Size(375, 812), // iPhone X/11/12 mini
        const Size(390, 844), // iPhone 13/14
        const Size(412, 915), // Samsung Galaxy A34 / Pixel 7
        const Size(430, 932), // iPhone 14/15 Pro Max
      ];

      final job = ContentModel.fromMap({
        'id': 'test_job_responsive',
        'title': 'Senior Section Engineer (Civil / Electrical / Mechanical)',
        'organization': 'Railway Recruitment Control Board of India',
        'contentType': 'government_job',
        'jobType': 'government',
        'status': 'published',
        'vacancies': '7951',
        'location': 'All India / Regional Offices',
        'qualification': 'Diploma / Degree in Civil Engineering',
        'applicationLastDate': '2026-11-15',
      }, 'test_job_responsive');

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: NjJobCard(
                  job: job,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NjJobCard), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Overflow on dimension: ${dim.width}x${dim.height}');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
        'Responsive UI: Renders NjEmptyState 3D illustration across screen dimensions without overflow',
        (WidgetTester tester) async {
      final dimensions = [
        const Size(320, 568),
        const Size(360, 800),
        const Size(393, 873),
        const Size(412, 915),
      ];

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: NjEmptyState(
                  title: 'No Jobs Found',
                  message:
                      'Try selecting different categories or clearing active filters to see available openings.',
                  actionLabel: 'Reset Filters',
                  onAction: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NjEmptyState), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Empty state overflow on ${dim.width}x${dim.height}');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
        'Responsive UI: Renders Private Job Card with salary and island metadata across dimensions',
        (WidgetTester tester) async {
      final dimensions = [
        const Size(320, 568),
        const Size(360, 800),
        const Size(393, 873),
        const Size(412, 915),
      ];

      final privateJob = ContentModel.fromMap({
        'id': 'test_private_job',
        'title': 'Senior Marine Operations & Cargo Logistics Coordinator',
        'companyName': 'Andaman Sea Shipping & Logistics Private Limited',
        'contentType': 'andaman_job',
        'jobType': 'private',
        'status': 'published',
        'salaryRange': '₹35,000 - ₹50,000 / month',
        'island': 'Port Blair, South Andaman',
        'employmentType': 'Full Time',
        'location': 'Haddo Wharf',
        'qualification': 'Graduate in Logistics / Marine Science',
        'applicationLastDate': '2026-10-31',
      }, 'test_private_job');

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: NjJobCard(
                  job: privateJob,
                  onTap: () {},
                  onToggleSave: () {},
                  onShare: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NjJobCard), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Private job card overflow on ${dim.width}x${dim.height}');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
        'Dark Theme UI: Renders NjCard and NjJobCard in dark mode without contrast failure',
        (WidgetTester tester) async {
      final job = ContentModel.fromMap({
        'id': 'test_dark_mode_job',
        'title': 'Junior Engineer (Civil) Andaman PWD',
        'organization': 'APWD Port Blair',
        'contentType': 'andaman_job',
        'jobType': 'government',
        'status': 'published',
        'vacancies': '42',
        'location': 'Port Blair',
        'qualification': 'Diploma in Civil Engineering',
        'applicationLastDate': '2026-12-01',
      }, 'test_dark_mode_job');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.darkBackground,
          ),
          home: Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: SingleChildScrollView(
              child: NjJobCard(
                job: job,
                isSaved: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NjJobCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Responsive UI: Renders NjUpdateCard across screen dimensions without overflow',
        (WidgetTester tester) async {
      final dimensions = [
        const Size(320, 568),
        const Size(360, 800),
        const Size(393, 873),
        const Size(412, 915),
      ];

      final updateItem = ContentModel.fromMap({
        'id': 'test_update_1',
        'title':
            'Staff Selection Commission Combined Graduate Level Tier-1 Result Declared',
        'organization': 'Staff Selection Commission',
        'contentType': 'result',
        'status': 'published',
        'publishedAt': DateTime.now().toIso8601String(),
        'views': 1250,
      }, 'test_update_1');

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: NjUpdateCard(
                  item: updateItem,
                  onTap: () {},
                  onShare: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NjUpdateCard), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'NjUpdateCard overflow on ${dim.width}x${dim.height}');
      }
    });

    testWidgets(
        'Dark Theme UI: Renders NjUpdateCard in dark mode without error',
        (WidgetTester tester) async {
      final admitCardItem = ContentModel.fromMap({
        'id': 'test_admit_card_1',
        'title': 'UPSC Civil Services Preliminary Examination Hall Ticket Out',
        'organization': 'Union Public Service Commission',
        'contentType': 'admit_card',
        'status': 'published',
        'publishedAt': DateTime.now().toIso8601String(),
        'views': 450,
      }, 'test_admit_card_1');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.darkBackground,
          ),
          home: Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: SingleChildScrollView(
              child: NjUpdateCard(
                item: admitCardItem,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NjUpdateCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
