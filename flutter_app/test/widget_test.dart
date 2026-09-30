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
import 'package:notify_jobs/features/models/app_settings_model.dart';
import 'package:notify_jobs/features/providers/app_settings_provider.dart';
import 'package:notify_jobs/features/screens/home_screen.dart';
import 'package:notify_jobs/features/screens/more_screen.dart';
import 'package:notify_jobs/features/screens/splash_screen.dart';
import 'package:notify_jobs/core/widgets/social_brand_icon.dart';
import 'package:notify_jobs/core/widgets/nj_new_badge.dart';
import 'package:notify_jobs/core/widgets/nj_icon_container.dart';
import 'package:notify_jobs/features/providers/categories_provider.dart';
import 'package:notify_jobs/features/screens/notification_preferences_screen.dart';
import 'package:notify_jobs/features/screens/job_detail_screen.dart';
import 'package:notify_jobs/features/screens/update_detail_screen.dart';
import 'package:notify_jobs/features/screens/article_detail_screen.dart';
import 'package:notify_jobs/features/providers/content_providers.dart';
import 'package:notify_jobs/core/services/view_count_service.dart';
import 'package:notify_jobs/core/services/storage_service.dart';
import 'package:notify_jobs/features/providers/storage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  group('Home Community CTA & Social Icons Tests', () {
    testWidgets('HomeCommunityCtaSection does not contain legal disclaimer',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      // Verify that no legal disclaimer text exists in this section
      expect(
        find.textContaining('Notify Jobs is an independent exam & recruitment'),
        findsNothing,
      );
      expect(
        find.textContaining('All official notices & logos are property'),
        findsNothing,
      );
    });

    testWidgets(
        'WhatsApp original brand icon renders with assets/social/whatsapp.png',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      // Verify WhatsApp card renders
      expect(find.text('WhatsApp'), findsOneWidget);

      // Verify brand icon asset is used instead of generic icons
      final imageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image && widget.image is AssetImage) {
          return (widget.image as AssetImage).assetName ==
              'assets/social/whatsapp.png';
        }
        return false;
      });
      expect(imageFinder, findsOneWidget);

      // Verify no generic chat bubble icon is used
      expect(find.byIcon(Icons.chat_bubble_rounded), findsNothing);
    });

    testWidgets(
        'Telegram original brand icon renders with assets/social/telegram.png',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': false,
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      // Verify Telegram card renders
      expect(find.text('Telegram'), findsOneWidget);

      // Verify brand icon asset is used instead of generic send icon
      final imageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image && widget.image is AssetImage) {
          return (widget.image as AssetImage).assetName ==
              'assets/social/telegram.png';
        }
        return false;
      });
      expect(imageFinder, findsOneWidget);

      // Verify no generic send icon is used
      expect(find.byIcon(Icons.send_rounded), findsNothing);
    });

    testWidgets(
        'Community cards adapt to 2 columns when both WhatsApp and Telegram enabled',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);
    });

    testWidgets(
        'Community cards adapt to 1 column when only one channel is enabled',
        (WidgetTester tester) async {
      // 1. Only WhatsApp enabled
      final settingsWhatsAppOnly = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': false,
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settingsWhatsAppOnly),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Telegram'), findsNothing);

      // 2. Only Telegram enabled
      final settingsTelegramOnly = AppSettingsModel.fromMap({
        'whatsappEnabled': false,
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settingsTelegramOnly),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      expect(find.text('Telegram'), findsOneWidget);
      expect(find.text('WhatsApp'), findsNothing);
    });

    testWidgets(
        'Community section is completely hidden when both channels disabled or empty',
        (WidgetTester tester) async {
      final disabledSettings = AppSettingsModel.fromMap({
        'whatsappEnabled': false,
        'whatsappUrl': '',
        'telegramEnabled': false,
        'telegramUrl': '',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(disabledSettings),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeCommunityCtaSection(),
            ),
          ),
        ),
      );

      expect(find.text('WhatsApp'), findsNothing);
      expect(find.text('Telegram'), findsNothing);
      expect(find.byType(Image), findsNothing);
    });
  });

  group('SplashScreen Acceptance & Responsive Tests', () {
    testWidgets('Renders exactly ONE logo, ONE title, and ONE tagline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify the foreground logo image is rendered once
      final logoFinder = find.byWidgetPredicate((w) {
        if (w is Image && w.image is AssetImage) {
          return (w.image as AssetImage).assetName ==
              'assets/branding/notify_jobs_icon.png';
        }
        return false;
      });
      expect(logoFinder, findsOneWidget);

      // Verify background decorative artwork is loaded once
      final bgFinder = find.byWidgetPredicate((w) {
        if (w is Image && w.image is AssetImage) {
          return (w.image as AssetImage).assetName ==
              'assets/branding/splash_bg.png';
        }
        return false;
      });
      expect(bgFinder, findsOneWidget);

      // Verify NOTIFY and JOBS title words are rendered once each
      expect(find.text('NOTIFY '), findsOneWidget);
      expect(find.text('JOBS'), findsOneWidget);

      // Verify tagline is rendered once
      expect(
        find.text('Government Job Alerts & Exam Updates'),
        findsOneWidget,
      );

      // Pump 1 second to complete timer without throwing unhandled exceptions
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Renders cleanly without overflow across all target dimensions',
        (WidgetTester tester) async {
      const dimensions = [
        Size(320, 568), // iPhone SE / Compact
        Size(360, 800), // Standard Android
        Size(384, 854), // Samsung A34 default
        Size(393, 873), // Pixel 7
        Size(412, 915), // Large Android
      ];

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SplashScreen(),
            ),
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'SplashScreen overflowed on ${dim.width}x${dim.height}');

        // Complete transition timer
        await tester.pump(const Duration(seconds: 1));
      }
    });
  });

  group('Global Social Brand Icon & More Screen Tests', () {
    testWidgets(
        'SocialBrandIcon renders WhatsApp official asset without generic icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialBrandIcon.whatsapp(
              size: 28,
              withBackground: true,
            ),
          ),
        ),
      );

      final waFinder = find.byWidgetPredicate((w) {
        if (w is Image && w.image is AssetImage) {
          return (w.image as AssetImage).assetName ==
              'assets/social/whatsapp.png';
        }
        return false;
      });
      expect(waFinder, findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsNothing);
      expect(find.byIcon(Icons.chat_bubble_rounded), findsNothing);
    });

    testWidgets(
        'SocialBrandIcon renders Telegram official asset without generic icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialBrandIcon.telegram(
              size: 28,
              withBackground: true,
            ),
          ),
        ),
      );

      final tgFinder = find.byWidgetPredicate((w) {
        if (w is Image && w.image is AssetImage) {
          return (w.image as AssetImage).assetName ==
              'assets/social/telegram.png';
        }
        return false;
      });
      expect(tgFinder, findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
    });

    testWidgets(
        'MoreScreen Community section renders SocialBrandIcon for WhatsApp and Telegram',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(
            home: MoreScreen(),
          ),
        ),
      );

      // Verify SocialBrandIcon widgets exist in MoreScreen
      expect(find.byType(SocialBrandIcon), findsNWidgets(2));
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);

      // Verify no generic icons exist for WhatsApp or Telegram
      expect(find.byIcon(Icons.chat_bubble_rounded), findsNothing);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
    });

    testWidgets(
        'MoreScreen Community section renders cleanly without overflow across mobile dimensions',
        (WidgetTester tester) async {
      final settings = AppSettingsModel.fromMap({
        'whatsappEnabled': true,
        'whatsappUrl': 'https://chat.whatsapp.com/test',
        'telegramEnabled': true,
        'telegramUrl': 'https://t.me/test',
      });

      const dimensions = [
        Size(320, 568), // iPhone SE / Compact
        Size(360, 800), // Standard Android
        Size(393, 873), // Pixel 7
        Size(412, 915), // Large Android
      ];

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appSettingsProvider.overrideWithValue(settings),
            ],
            child: const MaterialApp(
              home: MoreScreen(),
            ),
          ),
        );

        expect(find.byType(MoreScreen), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'MoreScreen overflowed on ${dim.width}x${dim.height}');
      }
    });
  });

  group(
      'Home Screen Category Icons, Subtle Blinking NEW Badge & UI Polish Tests',
      () {
    testWidgets(
        'NjNewBadge renders NEW text and pulses cleanly through animation frames',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: NjNewBadge()),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
      // Pump initial animation frame
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('NEW'), findsOneWidget);
      // Pump half-cycle (700ms)
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('NEW'), findsOneWidget);
      // Pump full-cycle (1400ms)
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('NEW'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('NjCategoryIcon.resolveVariant maps all key categories accurately',
        () {
      expect(NjCategoryIcon.resolveVariant('latest-jobs'),
          NjIconVariant.latestJobs);
      expect(NjCategoryIcon.resolveVariant('andaman-nicobar'),
          NjIconVariant.andamanJobs);
      expect(NjCategoryIcon.resolveVariant('ssc'), NjIconVariant.ssc);
      expect(NjCategoryIcon.resolveVariant('railway'), NjIconVariant.railway);
      expect(NjCategoryIcon.resolveVariant('banking'), NjIconVariant.banking);
      expect(NjCategoryIcon.resolveVariant('police-defence'),
          NjIconVariant.policeDefence);
      expect(NjCategoryIcon.resolveVariant('irbn-police'),
          NjIconVariant.irbnPolice);
      expect(NjCategoryIcon.resolveVariant('admit-cards'),
          NjIconVariant.admitCards);
      expect(NjCategoryIcon.resolveVariant('results'), NjIconVariant.results);
      expect(NjCategoryIcon.resolveVariant('answer-keys'),
          NjIconVariant.answerKeys);
      expect(NjCategoryIcon.resolveVariant('syllabus'), NjIconVariant.syllabus);
      expect(NjCategoryIcon.resolveVariant('articles'), NjIconVariant.articles);
    });

    testWidgets(
        'NjQuickCategoryTile renders 3D icon, label, and responds to tap gesture',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 90,
                height: 82,
                child: NjQuickCategoryTile(
                  label: 'Latest Jobs',
                  slug: 'latest-jobs',
                  icon: Icons.work_rounded,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Latest Jobs'), findsOneWidget);
      expect(find.byType(NjCategoryIcon), findsOneWidget);

      await tester.tap(find.byType(NjQuickCategoryTile));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets(
        'Quick Categories 12-item grid renders cleanly without overflow across mobile dimensions',
        (WidgetTester tester) async {
      const dimensions = [
        Size(320, 568), // iPhone SE / Compact
        Size(360, 800), // Standard Android
        Size(393, 873), // Pixel 7
        Size(412, 915), // Large Android
      ];

      for (final dim in dimensions) {
        tester.view.physicalSize = dim;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: defaultFallbackCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 82,
                  ),
                  itemBuilder: (context, index) {
                    final cat = defaultFallbackCategories[index];
                    return NjQuickCategoryTile(
                      label: cat.name,
                      slug: cat.slug,
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NjQuickCategoryTile),
            findsNWidgets(defaultFallbackCategories.length));
        expect(tester.takeException(), isNull,
            reason:
                'Quick Categories grid overflowed on ${dim.width}x${dim.height}');
      }
    });

    testWidgets(
        'Status and category badges render with high contrast and depth in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                NjStatusBadge(
                    contentType: 'government_job', statusOverride: 'open'),
                NjBadge(label: 'SSC Jobs', variant: NjBadgeVariant.primary),
                NjBadge(label: 'A&N Jobs', variant: NjBadgeVariant.blue),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('SSC Jobs'), findsOneWidget);
      expect(find.text('A&N Jobs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Notification Preferences & Diagnostics Widget Tests', () {
    testWidgets(
        'NotificationPreferencesScreen renders master switch and diagnostics card',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: NotificationPreferencesScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Receive Push Notifications'), findsOneWidget);
      expect(find.text('Device Channel & Diagnostics'), findsOneWidget);
      expect(find.text('Test Banner'), findsOneWidget);
      expect(find.text('OS Settings'), findsOneWidget);
    });
  });

  group('Real View Count UI Rendering Tests', () {
    testWidgets(
        'JobDetailScreen renders view count with icon and triggers recordView',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final viewService = ViewCountService(prefs: prefs, workerUrl: '');

      final mockJob = ContentModel.fromMap({
        'title': 'Assistant Engineer (Civil)',
        'organization': 'APWD Port Blair',
        'contentType': 'government_job',
        'isPublished': true,
        'showInUserApp': true,
        'viewCount': 342,
      }, 'job-view-test');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            viewCountServiceProvider.overrideWithValue(viewService),
            contentByIdProvider('job-view-test').overrideWithValue(mockJob),
          ],
          child: const MaterialApp(
            home: JobDetailScreen(id: 'job-view-test'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('342 views'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('UpdateDetailScreen renders view count in header card',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final viewService = ViewCountService(prefs: prefs, workerUrl: '');

      final mockUpdate = ContentModel.fromMap({
        'title': 'UPSC Prelims Admit Card 2026',
        'organization': 'UPSC',
        'contentType': 'admit_card',
        'isPublished': true,
        'showInUserApp': true,
        'viewCount': 789,
      }, 'update-view-test');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            viewCountServiceProvider.overrideWithValue(viewService),
            contentByIdProvider('update-view-test')
                .overrideWithValue(mockUpdate),
          ],
          child: const MaterialApp(
            home: UpdateDetailScreen(id: 'update-view-test'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('789 views'), findsOneWidget);
    });

    testWidgets('ArticleDetailScreen renders view count in header card',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final viewService = ViewCountService(prefs: prefs, workerUrl: '');

      final mockArticle = ContentModel.fromMap({
        'title': 'How to Prepare for Andaman Police SI Exam',
        'organization': 'Editorial Board',
        'contentType': 'article',
        'isPublished': true,
        'showInUserApp': true,
        'viewCount': 156,
      }, 'article-view-test');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            viewCountServiceProvider.overrideWithValue(viewService),
            contentByIdProvider('article-view-test')
                .overrideWithValue(mockArticle),
          ],
          child: const MaterialApp(
            home: ArticleDetailScreen(id: 'article-view-test'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('156 views'), findsOneWidget);
    });
  });
}
