import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_empty_state.dart';
import '../../core/widgets/nj_icon_container.dart';
import '../providers/notification_providers.dart';

/// Notification Inbox Screen (Specification 14, 22)
/// Groups: Today, Yesterday, Earlier
class NotificationInboxScreen extends ConsumerStatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  ConsumerState<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState
    extends ConsumerState<NotificationInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationStateProvider.notifier).markAllAsSeen();
    });
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text(
          'This will clear all notifications from your inbox. You can still find all updates in the respective sections.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(notificationStateProvider.notifier).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifState = ref.watch(notificationStateProvider);
    final notifications = notifState.items;

    final now = DateTime.now();
    final today = <AppNotificationItem>[];
    final yesterday = <AppNotificationItem>[];
    final earlier = <AppNotificationItem>[];

    final yesterdayDate = now.subtract(const Duration(days: 1));

    for (final n in notifications) {
      if (n.timestamp.year == now.year &&
          n.timestamp.month == now.month &&
          n.timestamp.day == now.day) {
        today.add(n);
      } else if (n.timestamp.year == yesterdayDate.year &&
          n.timestamp.month == yesterdayDate.month &&
          n.timestamp.day == yesterdayDate.day) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _showClearAllDialog,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const NjEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications Yet',
              message:
                  'New government job and exam notifications will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                if (today.isNotEmpty) ...[
                  _buildSectionHeader('Today', today.length, isDark),
                  ...today.map((item) => _buildNotificationTile(item, isDark)),
                ],
                if (yesterday.isNotEmpty) ...[
                  _buildSectionHeader('Yesterday', yesterday.length, isDark),
                  ...yesterday
                      .map((item) => _buildNotificationTile(item, isDark)),
                ],
                if (earlier.isNotEmpty) ...[
                  _buildSectionHeader('Earlier', earlier.length, isDark),
                  ...earlier
                      .map((item) => _buildNotificationTile(item, isDark)),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(AppNotificationItem item, bool isDark) {
    Color typeBg = const Color(0xFFE2E8F0);
    Color typeColor = const Color(0xFF334155);
    if (item.type == 'JOB') {
      typeBg = const Color(0xFFDCFCE7);
      typeColor = const Color(0xFF15803D);
    } else if (item.type == 'RESULT') {
      typeBg = const Color(0xFFFFEDD5);
      typeColor = const Color(0xFFC2410C);
    } else if (item.type == 'ADMIT CARD') {
      typeBg = const Color(0xFFF3E8FF);
      typeColor = const Color(0xFF7E22CE);
    } else if (item.type == 'ANSWER KEY') {
      typeBg = const Color(0xFFE0F2FE);
      typeColor = const Color(0xFF0369A1);
    }

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(notificationStateProvider.notifier).markItemRead(item.id);
        context.push(item.destination);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.transparent
              : (isDark
                  ? AppColors.royalBlue.withOpacity(0.08)
                  : const Color(0xFFEFF6FF)),
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Category Icon
            NjCategoryIcon(
              categorySlug: item.type.toLowerCase().replaceAll(' ', '-'),
              size: 38,
              iconSize: 18,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: typeColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, h:mm a').format(item.timestamp),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13.5,
                      fontWeight:
                          item.isRead ? FontWeight.w500 : FontWeight.w700,
                      color:
                          isDark ? AppColors.darkTextPrimary : AppColors.navy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: AppTypography.caption.copyWith(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(top: 6, left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.royalBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
