import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../utils/status_engine.dart';

/// Dynamic Application Deadline & Content Status Badge (Specification 63 & 129)
class NjStatusBadge extends StatelessWidget {
  final String? contentType;
  final String? applicationLastDate;
  final String? statusOverride;
  final dynamic lastDate;

  const NjStatusBadge({
    super.key,
    this.contentType,
    this.applicationLastDate,
    this.statusOverride,
    this.lastDate,
  });

  /// Factory helper for backwards compatibility
  static ({String label, Color color, Color bgColor}) computeStatus({
    String? contentType,
    String? applicationLastDate,
    String? statusOverride,
    dynamic lastDate,
  }) {
    DateTime? resolvedLastDate;
    if (lastDate is DateTime) {
      resolvedLastDate = lastDate;
    } else if (lastDate != null) {
      resolvedLastDate = DateTime.tryParse(lastDate.toString().trim());
    } else if (applicationLastDate != null &&
        applicationLastDate.trim().isNotEmpty) {
      resolvedLastDate = DateTime.tryParse(applicationLastDate.trim());
    }

    final computed = StatusEngine.compute(
      contentType: contentType ?? 'government_job',
      lastDate: resolvedLastDate,
      explicitStatus: statusOverride,
    );

    return (
      label: computed.label,
      color: computed.foregroundColor,
      bgColor: computed.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? resolvedLastDate;
    if (lastDate is DateTime) {
      resolvedLastDate = lastDate;
    } else if (lastDate != null) {
      resolvedLastDate = DateTime.tryParse(lastDate.toString().trim());
    } else if (applicationLastDate != null &&
        applicationLastDate!.trim().isNotEmpty) {
      resolvedLastDate = DateTime.tryParse(applicationLastDate!.trim());
    }

    final status = StatusEngine.compute(
      contentType: contentType ?? 'government_job',
      lastDate: resolvedLastDate,
      explicitStatus: statusOverride,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? status.foregroundColor.withOpacity(0.18)
        : status.backgroundColor;
    final borderColor =
        isDark ? status.foregroundColor.withOpacity(0.40) : status.borderColor;
    final textColor = isDark
        ? Color.lerp(status.foregroundColor, Colors.white, 0.20)!
        : status.foregroundColor;
    final dotColor = isDark ? textColor : status.foregroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              status.label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
