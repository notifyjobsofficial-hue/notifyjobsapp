import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/storage_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_card.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  late bool _latestJobs;
  late bool _admitCards;
  late bool _results;
  late bool _dailyDigest;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _latestJobs = storage.getBool('topic_latest_jobs', defaultValue: true);
    _admitCards = storage.getBool('topic_admit_cards', defaultValue: true);
    _results = storage.getBool('topic_results', defaultValue: true);
    _dailyDigest = storage.getBool('topic_daily_digest', defaultValue: false);
  }

  Future<void> _updateTopic(String key, String topicName, bool value) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setBool(key, value);

    try {
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic(topicName);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
      }
    } catch (e) {
      debugPrint('FCM topic error ($topicName): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Instant Alert Channels',
                    style: AppTypography.headingSmall),
                const SizedBox(height: 6),
                Text(
                  'Choose which government exam notifications you want to receive directly on this device.',
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
                    _updateTopic('topic_latest_jobs', 'all_jobs', val);
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
                    _updateTopic('topic_results', 'results', val);
                  },
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  title: 'Daily Digest & Deadline Warnings',
                  subtitle: 'Reminders for jobs closing in the next 48 hours',
                  value: _dailyDigest,
                  onChanged: (val) {
                    setState(() => _dailyDigest = val);
                    _updateTopic('topic_daily_digest', 'daily_digest', val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Note: You can also manage app-level notification sounds and banners in your Android System Settings.',
              style: AppTypography.captionMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall),
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
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
