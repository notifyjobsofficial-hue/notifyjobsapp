import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/models/content_model.dart';

/// Premium Context-Aware Social Share Bottom Sheet (Specification 26–30 & 129)
class NjShareSheet extends StatelessWidget {
  final ContentModel content;
  final String shareBaseUrl;

  const NjShareSheet({
    super.key,
    required this.content,
    required this.shareBaseUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required ContentModel content,
    String shareBaseUrl = '',
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NjShareSheet(
        content: content,
        shareBaseUrl: shareBaseUrl,
      ),
    );
  }

  /// Construct context-aware share text (Specification 28)
  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln(content.title);
    buffer.writeln();

    if (content.organization.isNotEmpty) {
      buffer.writeln(content.organization);
      buffer.writeln();
    }

    if (content.vacancies.isNotEmpty) {
      buffer.writeln('Vacancies: ${content.vacancies}');
    }

    if (content.applicationLastDate != null &&
        content.applicationLastDate!.isNotEmpty) {
      buffer.writeln('Last Date: ${content.displayLastDate}');
    }

    final url = _getShareUrl();
    if (url.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('View full details:');
      buffer.writeln(url);
    }

    return buffer.toString().trim();
  }

  String _getShareUrl() {
    if (shareBaseUrl.isNotEmpty) {
      final cleanBase =
          shareBaseUrl.endsWith('/') ? shareBaseUrl : '$shareBaseUrl/';
      return '$cleanBase${content.slug}';
    }
    return content.sourceUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shareText = _generateShareText();
    final shareUrl = _getShareUrl();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),

            // Sheet Title
            Text(
              'Share Recruitment Alert',
              style: AppTypography.sectionHeading.copyWith(
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help fellow aspirants find this opportunity',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
            ),
            const SizedBox(height: 20),

            // Share Options 4-Column Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. WhatsApp
                _buildShareTarget(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'WhatsApp',
                  bgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  onTap: () async {
                    Navigator.pop(context);
                    final encoded = Uri.encodeComponent(shareText);
                    final uri = Uri.parse('whatsapp://send?text=$encoded');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      // Fallback to web
                      await launchUrl(
                        Uri.parse(
                            'https://api.whatsapp.com/send?text=$encoded'),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),

                // 2. Telegram
                _buildShareTarget(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  bgColor: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  onTap: () async {
                    Navigator.pop(context);
                    final encodedText = Uri.encodeComponent(shareText);
                    final encodedUrl = Uri.encodeComponent(shareUrl);
                    final uri = Uri.parse(
                        'https://t.me/share/url?url=$encodedUrl&text=$encodedText');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),

                // 3. Copy Link
                _buildShareTarget(
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  bgColor: const Color(0xFFF1F5F9),
                  iconColor: AppColors.navy,
                  onTap: () async {
                    Navigator.pop(context);
                    await Clipboard.setData(ClipboardData(text: shareUrl));
                    HapticFeedback.mediumImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),

                // 4. More (Android Native Share Sheet)
                _buildShareTarget(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  bgColor: const Color(0xFFF3E8FF),
                  iconColor: AppColors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(shareText, subject: content.title);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTarget({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
