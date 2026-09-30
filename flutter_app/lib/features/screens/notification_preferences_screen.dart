import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/storage_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_button.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen>
    with WidgetsBindingObserver {
  late bool _masterNotifications;
  late bool _latestJobs;
  late bool _andamanJobs;
  late bool _admitCards;
  late bool _results;
  late bool _dailyDigest;

  AuthorizationStatus? _permissionStatus;
  bool _isLoadingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final storage = ref.read(storageServiceProvider);
    _masterNotifications =
        storage.getBool('notifications_master_enabled', defaultValue: true);
    _latestJobs = storage.getBool('topic_latest_jobs', defaultValue: true);
    _andamanJobs = storage.getBool('topic_andaman_jobs', defaultValue: true);
    _admitCards = storage.getBool('topic_admit_cards', defaultValue: true);
    _results = storage.getBool('topic_results', defaultValue: true);
    _dailyDigest = storage.getBool('topic_daily_digest', defaultValue: false);

    _checkPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (mounted) {
        setState(() {
          _permissionStatus = settings.authorizationStatus;
          _isLoadingPermission = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPermission = false);
      }
    }
  }

  Future<void> _toggleMaster(bool value) async {
    final storage = ref.read(storageServiceProvider);
    setState(() => _masterNotifications = value);
    await storage.setBool('notifications_master_enabled', value);

    try {
      final messaging = FirebaseMessaging.instance;
      if (value) {
        await messaging.subscribeToTopic('all_users');
        await messaging.subscribeToTopic('all_updates');
        if (_latestJobs) await messaging.subscribeToTopic('all_jobs');
        if (_andamanJobs) await messaging.subscribeToTopic('andaman');
        if (_admitCards) await messaging.subscribeToTopic('admit_cards');
        if (_results) await messaging.subscribeToTopic('results');
        if (_dailyDigest) await messaging.subscribeToTopic('daily_digest');
      } else {
        await messaging.unsubscribeFromTopic('all_users');
        await messaging.unsubscribeFromTopic('all_updates');
        await messaging.unsubscribeFromTopic('all_jobs');
        await messaging.unsubscribeFromTopic('jobs');
        await messaging.unsubscribeFromTopic('andaman');
        await messaging.unsubscribeFromTopic('andaman_jobs');
        await messaging.unsubscribeFromTopic('admit_cards');
        await messaging.unsubscribeFromTopic('results');
        await messaging.unsubscribeFromTopic('daily_digest');
      }
    } catch (e) {
      debugPrint('Master topic toggle note: $e');
    }
  }

  Future<void> _updateTopic(String key, String topicName, bool value,
      {String? secondaryTopic}) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setBool(key, value);

    try {
      final messaging = FirebaseMessaging.instance;
      if (value && _masterNotifications) {
        await messaging.subscribeToTopic(topicName);
        if (secondaryTopic != null) {
          await messaging.subscribeToTopic(secondaryTopic);
        }
      } else {
        await messaging.unsubscribeFromTopic(topicName);
        if (secondaryTopic != null) {
          await messaging.unsubscribeFromTopic(secondaryTopic);
        }
      }
    } catch (e) {
      debugPrint('FCM topic error ($topicName): $e');
    }
  }

  Future<void> _triggerTestAlert() async {
    final ok = await NotificationService.showTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Test notification dispatched to device banner!'
              : 'Could not show test banner. Please check Android notification permissions.',
        ),
        backgroundColor: ok ? AppColors.primary : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPermissionDenied = _permissionStatus == AuthorizationStatus.denied;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Android Permission Status Banner
          if (!_isLoadingPermission && isPermissionDenied)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Android Notifications Disabled',
                        style: AppTypography.titleSmall.copyWith(
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your device system settings are blocking notifications for Notify Jobs. Enable notifications to receive job and exam alerts.',
                    style: AppTypography.captionMedium
                        .copyWith(color: const Color(0xFF7F1D1D)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: NjButton(
                      label: 'Open Android Notification Settings',
                      icon: Icons.settings_outlined,
                      size: NjButtonSize.sm,
                      variant: NjButtonVariant.primary,
                      onPressed: () =>
                          NotificationService.openSystemNotificationSettings(),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Master Alert Switch Card
          NjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSwitchTile(
                  title: 'Receive Push Notifications',
                  subtitle:
                      'Enable or disable all notifications from Notify Jobs',
                  value: _masterNotifications,
                  onChanged: _toggleMaster,
                  isBoldTitle: true,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OS Permission Status:',
                      style: AppTypography.captionMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      _isLoadingPermission
                          ? 'Checking...'
                          : isPermissionDenied
                              ? 'Denied (Blocked by OS)'
                              : 'Allowed (Active)',
                      style: AppTypography.captionMedium.copyWith(
                        color: isPermissionDenied
                            ? Colors.red
                            : const Color(0xFF159B76),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Category Subscriptions Card
          AnimatedOpacity(
            opacity: _masterNotifications ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_masterNotifications,
              child: NjCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alert Categories',
                        style: AppTypography.headingSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Customize notifications based on the exams and regions you are targeting.',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      title: 'Latest Job Openings',
                      subtitle:
                          'Central & State Government recruitments, SSC, UPSC, Railways, Banking',
                      value: _latestJobs,
                      onChanged: (val) {
                        setState(() => _latestJobs = val);
                        _updateTopic('topic_latest_jobs', 'all_jobs', val,
                            secondaryTopic: 'jobs');
                      },
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      title: 'Andaman & Nicobar Openings',
                      subtitle:
                          'Direct recruitments, DBRAIT, PBMC, and local islands vacancies',
                      value: _andamanJobs,
                      onChanged: (val) {
                        setState(() => _andamanJobs = val);
                        _updateTopic('topic_andaman_jobs', 'andaman', val,
                            secondaryTopic: 'andaman_jobs');
                      },
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      title: 'Admit Card Alerts',
                      subtitle:
                          'Hall tickets, exam city intimation slips, and exam date notices',
                      value: _admitCards,
                      onChanged: (val) {
                        setState(() => _admitCards = val);
                        _updateTopic('topic_admit_cards', 'admit_cards', val);
                      },
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      title: 'Results & Answer Keys',
                      subtitle:
                          'Merit lists, cut-off marks, score cards, and provisional answer keys',
                      value: _results,
                      onChanged: (val) {
                        setState(() => _results = val);
                        _updateTopic('topic_results', 'results', val,
                            secondaryTopic: 'answer_keys');
                      },
                    ),
                    const Divider(height: 24),
                    _buildSwitchTile(
                      title: 'Daily Digest & Deadline Warnings',
                      subtitle:
                          'Reminders for jobs closing in the next 48 hours',
                      value: _dailyDigest,
                      onChanged: (val) {
                        setState(() => _dailyDigest = val);
                        _updateTopic('topic_daily_digest', 'daily_digest', val);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Device Diagnostics & Test Card
          NjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phonelink_setup_rounded,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Device Channel & Diagnostics',
                        style: AppTypography.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Channel: ${NotificationService.channelId} (High Importance)',
                  style: AppTypography.captionMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Icon: @drawable/ic_stat_notify_jobs (Monochrome Silhouette)',
                  style: AppTypography.captionMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.notifications_active_outlined,
                            size: 16),
                        label: const Text('Test Banner',
                            style: TextStyle(fontSize: 12)),
                        onPressed: _triggerTestAlert,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('OS Settings',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () => NotificationService
                            .openSystemNotificationSettings(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isBoldTitle = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: isBoldTitle
                    ? AppTypography.titleMedium
                        .copyWith(fontWeight: FontWeight.bold)
                    : AppTypography.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
