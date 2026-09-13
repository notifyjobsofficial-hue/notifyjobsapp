import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_button.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String? playStoreUrl;

  const UpdateRequiredScreen({super.key, this.playStoreUrl});

  Future<void> _openPlayStore(BuildContext context) async {
    final url = playStoreUrl ??
        'https://play.google.com/store/apps/details?id=com.notifyjobs.app';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Play Store.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      size: 54,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Update Required',
                    style: AppTypography.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A new version of Notify Jobs is available with essential security, performance, and notification improvements. Please update to continue using the app.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  NjButton(
                    label: 'Update Now on Play Store',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => _openPlayStore(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
