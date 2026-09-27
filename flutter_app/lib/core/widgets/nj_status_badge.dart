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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: status.borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status.foregroundColor,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              status.label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: status.foregroundColor,
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
