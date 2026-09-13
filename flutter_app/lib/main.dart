import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'features/providers/app_settings_provider.dart';
import 'features/providers/storage_provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_router.dart';
import 'features/screens/maintenance_screen.dart';
import 'features/screens/update_required_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint('Handling FCM background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistent key-value store
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);

  // 2. Initialize Firebase Core safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    final messaging = FirebaseMessaging.instance;
    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
        'User notification permission status: ${notifSettings.authorizationStatus}');

    // Subscribe to default general topics if first launch
    final isFirstLaunch =
        storageService.getBool('is_first_launch', defaultValue: true);
    if (isFirstLaunch) {
      await messaging.subscribeToTopic('all_jobs');
      await messaging.subscribeToTopic('admit_cards');
      await messaging.subscribeToTopic('results');
      await storageService.setBool('is_first_launch', false);
    }
  } catch (e) {
    debugPrint(
        'Firebase initialization note: $e (using local mock/offline fallback)');
  }

  // 3. Initialize Google Mobile Ads SDK safely
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization note: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const NotifyJobsApp(),
    ),
  );
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
      });
    } catch (_) {}
  }

  void _handleFcmMessage(RemoteMessage message) {
    final route = message.data['route'] ?? message.data['target_url'];
    final contentId = message.data['contentId'] ?? message.data['jobId'];

    if (route != null && route.toString().isNotEmpty) {
      appRouter.push(route.toString());
    } else if (contentId != null && contentId.toString().isNotEmpty) {
      final category = message.data['category'] ?? 'latest_jobs';
      if (category == 'latest_jobs') {
        appRouter.push('/job/$contentId');
      } else {
        appRouter.push('/article/$contentId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'Notify Jobs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) {
        // Check Remote Maintenance Mode
        if (settings.maintenanceMode) {
          return MaintenanceScreen(
            message: settings.maintenanceMessage,
          );
        }

        // Check Remote Force Update (current client version is 1.0.0)
        if (_isVersionOutdated('1.0.0', settings.minimumAppVersion)) {
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
