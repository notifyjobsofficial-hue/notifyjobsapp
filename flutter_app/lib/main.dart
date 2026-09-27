import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'features/providers/app_settings_provider.dart';
import 'features/providers/storage_provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/performance_tracker.dart';
import 'features/navigation/app_router.dart';
import 'features/screens/maintenance_screen.dart';
import 'features/screens/update_required_screen.dart';
import 'features/providers/content_providers.dart';
import 'features/providers/notification_providers.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint('Handling FCM background message: ${message.messageId}');
}

Future<void> _initBackgroundServices(StorageService storageService) async {
  // Non-blocking background initialization: FCM & AdMob
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
        'User notification permission status: ${notifSettings.authorizationStatus}');

    final isFirstLaunch =
        storageService.getBool('is_first_launch', defaultValue: true);
    if (isFirstLaunch) {
      await messaging.subscribeToTopic('all_jobs');
      await messaging.subscribeToTopic('admit_cards');
      await messaging.subscribeToTopic('results');
      await storageService.setBool('is_first_launch', false);
    }
  } catch (e) {
    debugPrint('Background Firebase Messaging note: $e');
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Background AdMob initialization note: $e');
  }
}

Future<void> main() async {
  PerformanceTracker.mark('MainStart');
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent Android experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Initialize local persistent key-value store (instant read)
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);
  PerformanceTracker.mark('PrefsLoaded');

  // 2. Initialize Firebase Core safely with offline disk persistence
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    PerformanceTracker.mark('FirebaseInit');
  } catch (e) {
    debugPrint(
        'Firebase initialization note: $e (using local mock/offline fallback)');
  }

  // 3. Render application immediately (Zero artificial delay / No white blank freeze)
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const NotifyJobsApp(),
    ),
  );

  // 4. Asynchronously initialize background services without blocking the main UI thread
  unawaited(_initBackgroundServices(storageService));
}

class NotifyJobsApp extends ConsumerStatefulWidget {
  const NotifyJobsApp({super.key});

  @override
  ConsumerState<NotifyJobsApp> createState() => _NotifyJobsAppState();
}

class _NotifyJobsAppState extends ConsumerState<NotifyJobsApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceTracker.mark('FirstFrame');
      PerformanceTracker.mark('HomeShell');
    });
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    try {
      // Check if opened from terminated state
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleFcmMessage(initialMessage);
      }

      // Listen to notification opens while app is backgrounded
      FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmMessage);

      // Listen to foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            'Foreground FCM notification: ${message.notification?.title}');
        ref.invalidate(firestoreContentStreamProvider);
      });
    } catch (_) {}
  }

  void _handleFcmMessage(RemoteMessage message) {
    try {
      final route = message.data['route'] ?? message.data['target_url'];
      final contentId = message.data['contentId'] ??
          message.data['jobId'] ??
          message.data['id'];

      if (contentId != null && contentId.toString().isNotEmpty) {
        ref
            .read(notificationStateProvider.notifier)
            .markItemRead(contentId.toString());
      }

      if (route != null && route.toString().isNotEmpty) {
        appRouter.push(route.toString());
        return;
      }

      if (contentId != null && contentId.toString().isNotEmpty) {
        final category = (message.data['category'] ??
                message.data['contentType'] ??
                'latest_jobs')
            .toString()
            .toLowerCase();
        if (category == 'latest_jobs' ||
            category == 'andaman_job' ||
            category == 'private_job' ||
            category == 'job' ||
            category == 'jobs' ||
            category == 'government_job') {
          appRouter.push('/job/$contentId');
        } else if (category == 'article') {
          appRouter.push('/article/$contentId');
        } else {
          // admit_card, result, answer_key, exam_date, syllabus, govt_update
          appRouter.push('/update/$contentId');
        }
      }
    } catch (e) {
      debugPrint('Error handling FCM notification route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Notify Jobs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        // Check Remote Maintenance Mode
        if (settings.maintenanceMode) {
          return MaintenanceScreen(
            message: settings.maintenanceMessage,
          );
        }

        // Check Remote Force Update (current client version is 1.1.0)
        if (_isVersionOutdated('1.1.0', settings.minimumAppVersion)) {
          return const UpdateRequiredScreen();
        }

        return child ?? const SizedBox.shrink();
      },
    );
  }

  bool _isVersionOutdated(String currentVersion, String minRequiredVersion) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final minParts = minRequiredVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final cur = i < currentParts.length ? currentParts[i] : 0;
        final req = i < minParts.length ? minParts[i] : 0;
        if (cur < req) return true;
        if (cur > req) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
