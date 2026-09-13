import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'nj_button.dart';

/// Friendly Error State Screen with Retry (Specification 99 & 129)
class NjErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const NjErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Something went wrong',
              style: AppTypography.sectionHeading.copyWith(
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message ??
                  'Could not connect to the recruitment feed. Please check your internet connection and try again.',
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            NjButton(
              label: 'Retry',
              size: NjButtonSize.md,
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: Colors.white),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
