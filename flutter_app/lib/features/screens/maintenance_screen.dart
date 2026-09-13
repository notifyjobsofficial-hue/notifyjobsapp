import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_button.dart';

class MaintenanceScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const MaintenanceScreen({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Icons.build_circle_outlined,
                    size: 54,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Under Scheduled Maintenance',
                  style: AppTypography.headingMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ??
                      'Notify Jobs is undergoing quick maintenance to bring you faster notifications and updates. Please check back shortly.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (onRetry != null)
                  NjButton(
                    label: 'Check Again',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
