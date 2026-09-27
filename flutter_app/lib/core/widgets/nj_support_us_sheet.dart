import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/models/app_settings_model.dart';
import 'nj_card.dart';

/// Support Us Bottom Sheet for Notify Jobs
/// Offers Community sharing, app rating, and direct user feedback/support.
class NjSupportUsSheet extends StatelessWidget {
  final AppSettingsModel settings;

  const NjSupportUsSheet({
    super.key,
    required this.settings,
  });

  static Future<void> show(BuildContext context, AppSettingsModel settings) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NjSupportUsSheet(settings: settings),
    );
  }

  void _handleShareApp(BuildContext context) {
    final playStoreUrl = settings.playStoreUrl.isNotEmpty
        ? settings.playStoreUrl
        : 'https://play.google.com/store/apps/details?id=com.notifyjobs.app';

    Share.share(
      'Download Notify Jobs App for Instant Sarkari Alerts, Admit Cards, and Results: $playStoreUrl',
      subject: 'Notify Jobs App',
    );
  }

  Future<void> _handleRateApp(BuildContext context) async {
    final playStoreUrl = settings.playStoreUrl.isNotEmpty
        ? settings.playStoreUrl
        : 'https://play.google.com/store/apps/details?id=com.notifyjobs.app';

    try {
      final uri = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _handleContactFeedback(BuildContext context) {
    Navigator.of(context).pop();
    context.push('/support');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Notify Jobs',
                        style: AppTypography.sectionHeading.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Help our free recruitment alert platform grow',
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              'Notify Jobs provides 100% free government recruitment updates. You can support this platform through any of the options below.',
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Option 1: Share Notify Jobs
            NjCard(
              onTap: () {
                Navigator.of(context).pop();
                _handleShareApp(context);
              },
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Notify Jobs',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Share with friends, study groups, and aspirants',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.secondaryText,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Option 2: Rate the App
            NjCard(
              onTap: () {
                Navigator.of(context).pop();
                _handleRateApp(context);
              },
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF16A34A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate the App',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Leave a review on Google Play Store',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.secondaryText,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Option 3: Contact & Feedback
            NjCard(
              onTap: () => _handleContactFeedback(context),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feedback & Support',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Send suggestions, questions, or report bugs',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.secondaryText,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Close button
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: AppTypography.button.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
