import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_card.dart';
import '../../core/widgets/nj_section_header.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  Future<void> _launch(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Channels Card
          NjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Direct Support Channels',
                    style: AppTypography.headingSmall),
                const SizedBox(height: 6),
                Text(
                  'Have questions, feedback, or noticed an error? Reach out directly.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                if (settings.supportEmail.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySubtle,
                      child:
                          Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    title: const Text('Official Support Email',
                        style: AppTypography.titleSmall),
                    subtitle: Text(settings.supportEmail,
                        style: AppTypography.bodySmall),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _launch(context,
                        'mailto:${settings.supportEmail}?subject=Notify Jobs Inquiry'),
                  ),
                if (settings.telegramUrl.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0F2FE),
                      child: Icon(Icons.send_rounded, color: Color(0xFF0284C7)),
                    ),
                    title: const Text('Join Telegram Community',
                        style: AppTypography.titleSmall),
                    subtitle: const Text('Instant alerts & discussion',
                        style: AppTypography.bodySmall),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _launch(context, settings.telegramUrl),
                  ),
                if (settings.whatsappUrl.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF16A34A)),
                    ),
                    title: const Text('WhatsApp Channel',
                        style: AppTypography.titleSmall),
                    subtitle: const Text('Daily digest on WhatsApp',
                        style: AppTypography.bodySmall),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _launch(context, settings.whatsappUrl),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Frequently Asked Questions
          const NjSectionHeader(
              title: 'Frequently Asked Questions', icon: Icons.quiz_outlined),
          const SizedBox(height: 8),

          _buildFaqTile(
            'Is Notify Jobs free to use?',
            'Yes, 100% free! Notify Jobs does not charge aspirants any fee, nor does it require any sign-up or phone number registration.',
          ),
          _buildFaqTile(
            'Are Apply Online and Official Website links direct?',
            'Yes. Apply Online and Official Website links open directly in your browser without any ads or intermediate redirects.',
          ),
          _buildFaqTile(
            'Why is there an ad before downloading notification PDFs?',
            'We support our independent research and operational servers by offering official PDF notices via optional rewarded ads. Once unlocked, the PDF download remains unlocked for 30 minutes on your device.',
          ),
          _buildFaqTile(
            'How do I save a job for offline reference?',
            'Tap the bookmark icon at the top right of any job post. Saved jobs are stored locally on your device and are accessible even without internet.',
          ),
          _buildFaqTile(
            'How can I report inaccurate information?',
            'We strive for 100% accuracy by citing official recruitment notices. If you detect any discrepancy, email us at ${settings.supportEmail} with the advertisement number and post name.',
          ),
          const SizedBox(height: 24),

          // Independent Portal Disclaimer
          NjCard(
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Independent Aspirant Service',
                    style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                Text(
                  'Notify Jobs is an independent public awareness portal. It is not affiliated with, endorsed by, or representing any Central or State Government recruitment agency.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: NjCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Text(question, style: AppTypography.titleSmall),
          children: [
            Text(
              answer,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
