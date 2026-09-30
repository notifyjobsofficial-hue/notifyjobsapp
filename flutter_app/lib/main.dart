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
import 'core/services/notification_service.dart';

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
  // Non-blocking background initialization: FCM background & AdMob
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
      // Initialize full notification lifecycle (channel, icon, foreground alert, deep links, core topics)
      ref.read(notificationServiceProvider).initialize(ref);
    });
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
