import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_support_us_sheet.dart';
import '../../core/widgets/social_brand_icon.dart';
import '../providers/app_settings_provider.dart';

/// More / Settings Screen cleanly structured with exactly 5 sections (Specification Part 6)
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _launchExternalUrl(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showDisclaimerDialog(BuildContext context, dynamic settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Official Disclaimer'),
        content: Text(
          settings.disclaimer.isNotEmpty
              ? settings.disclaimer
              : 'Notify Jobs is an independent information service and is NOT affiliated with, authorized, endorsed by, or in any way officially connected with any government agency or entity. All job notifications and exam updates are gathered from publicly accessible official sources.',
          style: AppTypography.body.copyWith(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, dynamic settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandOrange.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/branding/notify_jobs_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NOTIFY ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF111111),
                  ),
                ),
                Text(
                  'JOBS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.brandOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Government Job Alerts & Exam Updates',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Notify Jobs is a standalone, aspirant-focused mobile application built to provide instantaneous alerts for Indian government jobs, exam results, admit cards, and answer keys.\n\nAll official links open directly to authorized recruitment portals.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 12.5,
                height: 1.45,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: NOTIFICATIONS
              _buildSectionHeader('NOTIFICATIONS', isDark),
              const SizedBox(height: 10),
              NjCard(
                padding: EdgeInsets.zero,
                child: _buildListTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage alert categories and sound preferences',
                  onTap: () => context.push('/notification-preferences'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 2: APPEARANCE
              _buildSectionHeader('APPEARANCE', isDark),
              const SizedBox(height: 10),
              NjCard(
                padding: EdgeInsets.zero,
                child: _buildSwitchTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Dark Mode',
                  subtitle:
                      isDark ? 'Dark theme is active' : 'Light theme is active',
                  value: isDark,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 3: COMMUNITY
              _buildSectionHeader('COMMUNITY', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialTile(
                      platform: SocialPlatform.whatsapp,
                      label: 'WhatsApp',
                      onTap: () {
                        final url = settings.whatsappUrl.isNotEmpty
                            ? settings.whatsappUrl
                            : 'https://whatsapp.com';
                        _launchExternalUrl(url);
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSocialTile(
                      platform: SocialPlatform.telegram,
                      label: 'Telegram',
                      onTap: () {
                        final url = settings.telegramUrl.isNotEmpty
                            ? settings.telegramUrl
                            : 'https://telegram.me';
                        _launchExternalUrl(url);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // SECTION 4: SUPPORT NOTIFY JOBS
              _buildSectionHeader('SUPPORT NOTIFY JOBS', isDark),
              const SizedBox(height: 10),
              NjCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.favorite_rounded,
                      title: 'Support Us',
                      subtitle: 'Share the app, rate us, or send feedback',
                      iconColor: const Color(0xFFDC2626),
                      onTap: () => NjSupportUsSheet.show(context, settings),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.share_outlined,
                      title: 'Share App',
                      subtitle: 'Share Notify Jobs with fellow aspirants',
                      onTap: () {
                        final url = settings.playStoreUrl.isNotEmpty
                            ? settings.playStoreUrl
                            : 'https://play.google.com/store/apps/details?id=com.notifyjobs.app';
                        Share.share(
                          'Download Notify Jobs App for Instant Sarkari Alerts, Admit Cards, and Results: $url',
                          subject: 'Notify Jobs App',
                        );
                      },
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate App',
                      subtitle: 'Rate us 5 stars on Google Play Store',
                      onTap: () {
                        final url = settings.playStoreUrl.isNotEmpty
                            ? settings.playStoreUrl
                            : 'https://play.google.com/store/apps/details?id=com.notifyjobs.app';
                        _launchExternalUrl(url);
                      },
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.report_problem_outlined,
                      title: 'Report a Problem',
                      subtitle:
                          'Report incorrect details, broken links or bugs',
                      onTap: () => context.push('/support'),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Contact Us',
                      subtitle: 'Get in touch with the Notify Jobs team',
                      onTap: () => context.push('/support'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // SECTION 5: LEGAL
              _buildSectionHeader('LEGAL', isDark),
              const SizedBox(height: 10),
              NjCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our data safety declaration',
                      onTap: () => _launchExternalUrl(settings.privacyUrl),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Application usage guidelines',
                      onTap: () => _launchExternalUrl(settings.termsUrl),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.gavel_outlined,
                      title: 'Disclaimer',
                      subtitle: 'Independent notification portal declaration',
                      onTap: () => _showDisclaimerDialog(context, settings),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Notify Jobs',
                      subtitle: 'Independent exam & job alert platform',
                      onTap: () => _showAboutDialog(context, settings),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // App Version Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Notify Jobs v1.1',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Fast, Free & Independent Sarkari Alerts',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary.withOpacity(0.7)
                            : AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.sectionHeading.copyWith(
            fontSize: 13,
            letterSpacing: 0.8,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialTile({
    required SocialPlatform platform,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NjCard(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SocialBrandIcon(
            platform: platform,
            size: 28,
            withBackground: true,
            containerSize: 38,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: AppTypography.button.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.navy),
          ),
        ),
        title: Text(
          title,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: AppColors.muted),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
