import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_card.dart';
import '../providers/app_settings_provider.dart';

/// More / Hub Screen inspired by Maths Yoddha benchmark (Specification 33, 34, 155, 156)
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _launchExternalUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card (Maths Yoddha Inspired Solid Green Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Aspirant',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'NOTIFY JOBS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.tagline,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Section: Social Channels (| Join Us) (Specification 32)
              _buildSectionHeader('| Join Us', isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  // WhatsApp
                  if (settings.whatsappEnabled &&
                      settings.whatsappUrl.isNotEmpty)
                    Expanded(
                      child: _buildSocialTile(
                        label: 'WhatsApp',
                        icon: Icons.chat_bubble_rounded,
                        iconColor: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                        onTap: () => _launchExternalUrl(settings.whatsappUrl),
                        isDark: isDark,
                      ),
                    ),
                  if (settings.whatsappEnabled &&
                      settings.telegramEnabled &&
                      settings.telegramUrl.isNotEmpty)
                    const SizedBox(width: 12),
                  // Telegram
                  if (settings.telegramEnabled &&
                      settings.telegramUrl.isNotEmpty)
                    Expanded(
                      child: _buildSocialTile(
                        label: 'Telegram',
                        icon: Icons.send_rounded,
                        iconColor: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                        onTap: () => _launchExternalUrl(settings.telegramUrl),
                        isDark: isDark,
                      ),
                    ),
                ],
              ),
              if (settings.youtubeEnabled &&
                  settings.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialTile(
                        label: 'YouTube',
                        icon: Icons.play_arrow_rounded,
                        iconColor: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                        onTap: () => _launchExternalUrl(settings.youtubeUrl),
                        isDark: isDark,
                      ),
                    ),
                    if (settings.instagramEnabled &&
                        settings.instagramUrl.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSocialTile(
                          label: 'Instagram',
                          icon: Icons.camera_alt_rounded,
                          iconColor: const Color(0xFFDB2777),
                          bgColor: const Color(0xFFFCE7F3),
                          onTap: () =>
                              _launchExternalUrl(settings.instagramUrl),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // 3. Section: Preferences & Support (| Help & Support)
              _buildSectionHeader('| Preferences & Support', isDark),
              const SizedBox(height: 12),
              NjCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notification Preferences',
                      subtitle: 'Choose recruitment alert topics',
                      onTap: () => context.push('/notifications'),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.headset_mic_outlined,
                      title: 'Help & Support',
                      subtitle: 'Email, WhatsApp & report wrong info',
                      onTap: () => context.push('/support'),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.share_outlined,
                      title: 'Share Notify Jobs App',
                      subtitle: 'Share with friends & study groups',
                      onTap: () {
                        Share.share(
                          'Download Notify Jobs App for latest Government Jobs, Admit Cards and Results: ${settings.playStoreUrl}',
                        );
                      },
                      isDark: isDark,
                    ),
                    if (settings.playStoreUrl.isNotEmpty) ...[
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.star_outline_rounded,
                        title: 'Rate App on Play Store',
                        subtitle: 'Leave a 5-star review',
                        onTap: () => _launchExternalUrl(settings.playStoreUrl),
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Section: Legal & Policies
              _buildSectionHeader('| Information & Policies', isDark),
              const SizedBox(height: 12),
              NjCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Notify Jobs',
                      subtitle: 'Fast, independent exam alert platform',
                      onTap: () => _showAboutDialog(context, settings),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.gavel_outlined,
                      title: 'Disclaimer',
                      subtitle: 'Independent notification portal',
                      onTap: () => _showDisclaimerDialog(context, settings),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
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
                      title: 'Terms of Service',
                      subtitle: 'Usage guidelines',
                      onTap: () => _launchExternalUrl(settings.termsUrl),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Version Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Notify Jobs v${settings.latestAppVersion} (Build 1)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with ❤️ for Indian Aspirants',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
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
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.replaceFirst('| ', ''),
          style: AppTypography.sectionHeading.copyWith(
            fontSize: 15,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialTile({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NjCard(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTypography.button.copyWith(
              fontSize: 13,
              color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
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
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.navy),
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
    );
  }

  void _showDisclaimerDialog(BuildContext context, dynamic settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Official Disclaimer'),
        content: Text(
          settings.disclaimer,
          style: AppTypography.body.copyWith(fontSize: 13),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.appTitle),
        content: Text(
          'Notify Jobs is a standalone, aspirant-focused mobile application built to provide instantaneous alerts for Indian government jobs, exam results, admit cards, and answer keys.\n\nAll official links open directly to authorized recruitment portals.',
          style: AppTypography.body.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
