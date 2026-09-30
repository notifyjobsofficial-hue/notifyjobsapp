import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../../features/providers/storage_provider.dart';
import '../../features/providers/content_providers.dart';
import '../../features/providers/notification_providers.dart';
import '../../features/navigation/app_router.dart';

/// Central Notification Service for Notify Jobs
///
/// Features (Specification Part B, Items 8 - 28):
/// 1. Android 13+ Notification Runtime Permission handling
/// 2. Notification Channel 'notify_jobs_alerts' (High Importance, Sound, Vibration)
/// 3. Monochrome Notification Icon '@drawable/ic_stat_notify_jobs'
/// 4. Robust Topic Subscriptions ('all_users', 'jobs', 'admit_cards', 'results', 'andaman_jobs', etc.)
/// 5. Foreground Notification Display via flutter_local_notifications
/// 6. Deep link routing with safe missing-content fallback
/// 7. Native "Open App Notification Settings" via platform channel
/// 8. Debug-only device diagnostics
class NotificationService {
  static const String channelId = 'notify_jobs_alerts';
  static const String channelName = 'Notify Jobs Alerts';
  static const String channelDescription =
      'Instant alerts for government jobs, admit cards, and exam results';

  static const List<String> coreTopics = [
    'all_users',
    'all_updates',
    'all_jobs',
    'jobs',
    'admit_cards',
    'results',
    'andaman_jobs',
    'andaman',
    'updates',
  ];

  static const AndroidNotificationChannel androidChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _settingsChannel =
      MethodChannel('com.notifyjobs.app/settings');

  bool _isInitialized = false;

  NotificationService({StorageService? storage});

  /// Initialize local notification channels, FCM listeners, and core topics
  Future<void> initialize(WidgetRef? ref) async {
    if (_isInitialized) return;

    try {
      // 1. Initialize local notifications plugin
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_stat_notify_jobs');
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data =
                  jsonDecode(response.payload!) as Map<String, dynamic>;
              _handlePayloadRouting(data);
            } catch (e) {
              debugPrint('Local notification payload parsing error: $e');
            }
          }
        },
      );

      // 2. Create Android Notification Channel on device
      final androidPlatform =
          localNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(androidChannel);
      }

      // 3. Request Notification Permission
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization Status: ${settings.authorizationStatus}');

      // 4. Subscribe to core broadcast topics if allowed
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await subscribeToCoreTopics();
      }

      // 5. Setup FCM Message Handlers
      // A. Terminated launch
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleFcmMessage(initialMessage, ref);
      }

      // B. Background tap launch
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleFcmMessage(message, ref);
      });

      // C. Foreground notification received
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM received: ${message.notification?.title}');
        // Display notification banner
        showForegroundNotification(message);

        // Refresh providers
        if (ref != null) {
          ref.invalidate(firestoreContentStreamProvider);
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization note: $e');
    }
  }

  /// Subscribe device to all core broadcast topics with error safety
  Future<void> subscribeToCoreTopics() async {
    final messaging = FirebaseMessaging.instance;
    for (final topic in coreTopics) {
      try {
        await messaging.subscribeToTopic(topic);
        debugPrint('Subscribed to FCM topic: $topic');
      } catch (e) {
        debugPrint('Could not subscribe to topic $topic: $e');
      }
    }
  }

  /// Display a local system notification banner when FCM arrives in the foreground
  static Future<void> showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title'] ??
        'Notify Jobs Alert';
    final body = message.notification?.body ??
        message.data['body'] ??
        'Tap to view latest recruitment update.';

    final androidDetails = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      icon: '@drawable/ic_stat_notify_jobs',
      color: const Color(0xFFFF5A00),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await localNotificationsPlugin.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing local foreground notification: $e');
    }
  }

  /// Show a quick local test notification banner to verify audio, vibration, and monochrome icon
  static Future<bool> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      icon: '@drawable/ic_stat_notify_jobs',
      color: Color(0xFFFF5A00),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await localNotificationsPlugin.show(
        id: 9999,
        title: 'Notify Jobs: System Alert Ready',
        body:
            'Notification alerts with high importance and audio are working properly.',
        notificationDetails: notificationDetails,
        payload: jsonEncode({'route': '/notifications'}),
      );
      return true;
    } catch (e) {
      debugPrint('Error showing test notification: $e');
      return false;
    }
  }

  /// Handle incoming FCM message data for deep linking
  void _handleFcmMessage(RemoteMessage message, WidgetRef? ref) {
    if (ref != null) {
      final contentId = message.data['contentId'] ??
          message.data['jobId'] ??
          message.data['id'];
      if (contentId != null && contentId.toString().isNotEmpty) {
        ref
            .read(notificationStateProvider.notifier)
            .markItemRead(contentId.toString());
      }
    }

    _handlePayloadRouting(message.data);
  }

  /// Route user based on notification data payload with safe missing content fallback
  static void _handlePayloadRouting(Map<String, dynamic> data) {
    try {
      final route = data['route'] ?? data['target_url'];
      final contentId = data['contentId'] ?? data['jobId'] ?? data['id'];
      final contentType = (data['contentType'] ?? data['category'] ?? '')
          .toString()
          .toLowerCase();

      if (route != null && route.toString().trim().isNotEmpty) {
        appRouter.push(route.toString().trim());
        return;
      }

      if (contentId != null && contentId.toString().trim().isNotEmpty) {
        final id = contentId.toString().trim();
        if (contentType == 'article') {
          appRouter.push('/article/$id');
        } else if (contentType == 'admit_card' ||
            contentType == 'result' ||
            contentType == 'answer_key' ||
            contentType == 'syllabus') {
          appRouter.push('/update/$id');
        } else {
          appRouter.push('/job/$id');
        }
        return;
      }

      // Default fallback
      appRouter.push('/notifications');
    } catch (e) {
      debugPrint('Notification deep link navigation error: $e');
    }
  }

  /// Native intent helper to open Android System Notification Settings
  static Future<bool> openSystemNotificationSettings() async {
    try {
      final bool result =
          await _settingsChannel.invokeMethod('openNotificationSettings');
      return result;
    } catch (e) {
      debugPrint('openSystemNotificationSettings error: $e');
      return false;
    }
  }

  /// Check runtime notification permission status
  Future<NotificationSettings> getPermissionSettings() async {
    return await FirebaseMessaging.instance.getNotificationSettings();
  }

  /// Diagnostic telemetry for troubleshooting (Debug only)
  Future<Map<String, dynamic>> getDiagnostics() async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      token = 'Token unavailable: $e';
    }

    NotificationSettings? settings;
    try {
      settings = await FirebaseMessaging.instance.getNotificationSettings();
    } catch (_) {}

    return {
      'firebaseInitialized': Firebase.apps.isNotEmpty,
      'fcmToken': kDebugMode
          ? token
          : (token != null && token.isNotEmpty ? 'Token Active' : 'No Token'),
      'authorizationStatus':
          settings?.authorizationStatus.toString() ?? 'unknown',
      'channelId': channelId,
      'channelName': channelName,
      'subscribedTopics': coreTopics,
    };
  }
}

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationService(storage: storage);
});
