import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Dynamic Application Deadline Status Engine (Specification 63 & 129)
class NjStatusBadge extends StatelessWidget {
  final String? applicationLastDate;
  final String? statusOverride;
  final dynamic lastDate;

  const NjStatusBadge({
    super.key,
    this.applicationLastDate,
    this.statusOverride,
    this.lastDate,
  });

  static ({String label, Color color, Color bgColor}) computeStatus({
    String? applicationLastDate,
    String? statusOverride,
    dynamic lastDate,
  }) {
    String? resolvedDate = applicationLastDate;
    if (lastDate != null) {
      if (lastDate is DateTime) {
        resolvedDate = lastDate.toIso8601String();
      } else {
        resolvedDate = lastDate.toString();
      }
    }
    if (statusOverride != null &&
        statusOverride != 'auto' &&
        statusOverride.isNotEmpty) {
      switch (statusOverride) {
        case 'open':
          return (
            label: 'Open',
            color: AppColors.primary,
            bgColor: AppColors.softGreen,
          );
        case 'closing_soon':
          return (
            label: 'Closing Soon',
            color: const Color(0xFFD97706),
            bgColor: AppColors.amberSoft,
          );
        case 'closing_today':
          return (
            label: 'Closing Today',
            color: AppColors.error,
            bgColor: AppColors.errorSoft,
          );
        case 'closed':
          return (
            label: 'Closed',
            color: AppColors.muted,
            bgColor: const Color(0xFFF1F5F9),
          );
      }
    }

    if (resolvedDate == null || resolvedDate.trim().isEmpty) {
      return (
        label: 'Open',
        color: AppColors.primary,
        bgColor: AppColors.softGreen,
      );
    }

    try {
      final deadline = DateTime.parse(resolvedDate.trim());
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(deadline.year, deadline.month, deadline.day);

      final diffDays = target.difference(today).inDays;

      if (diffDays < 0) {
        return (
          label: 'Closed',
          color: AppColors.muted,
          bgColor: const Color(0xFFF1F5F9),
        );
      } else if (diffDays == 0) {
        return (
          label: 'Closing Today',
          color: AppColors.error,
          bgColor: AppColors.errorSoft,
        );
      } else if (diffDays <= 3) {
        return (
          label: 'Closing in ${diffDays}d',
          color: const Color(0xFFD97706),
          bgColor: AppColors.amberSoft,
        );
      } else {
        return (
          label: 'Open',
          color: AppColors.primary,
          bgColor: AppColors.softGreen,
        );
      }
    } catch (_) {
      return (
        label: 'Open',
        color: AppColors.primary,
        bgColor: AppColors.softGreen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = computeStatus(
      applicationLastDate: applicationLastDate,
      statusOverride: statusOverride,
      lastDate: lastDate,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: status.color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status.color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
