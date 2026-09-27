import 'package:flutter/material.dart';

/// Computed status metadata representing badge text, visual color, and priority
class ComputedStatus {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool isUrgent;

  const ComputedStatus({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    this.isUrgent = false,
  });
}

/// Dynamic Status Engine for Notify Jobs
class StatusEngine {
  StatusEngine._();

  /// Computes the precise, real-time dynamic status for any content item
  static ComputedStatus compute({
    required String contentType,
    DateTime? lastDate,
    DateTime? startDate,
    String? explicitStatus,
    DateTime? examDate,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Jobs (Government, Andaman, Private)
    if (contentType == 'government_job' ||
        contentType == 'andaman_job' ||
        contentType == 'private_job' ||
        contentType == 'job') {
      // Explicit Admin Override takes precedence if not 'auto'
      final normalizedExplicit = (explicitStatus ?? '').toLowerCase().trim();
      if (normalizedExplicit.isNotEmpty && normalizedExplicit != 'auto') {
        if (normalizedExplicit == 'closed') {
          return const ComputedStatus(
            label: 'Closed',
            foregroundColor: Color(0xFF64748B),
            backgroundColor: Color(0xFFF1F5F9),
            borderColor: Color(0xFFCBD5E1),
          );
        } else if (normalizedExplicit == 'closing_today' ||
            normalizedExplicit == 'last_day') {
          return const ComputedStatus(
            label: 'Closing Today',
            foregroundColor: Color(0xFFDC2626),
            backgroundColor: Color(0xFFFEF2F2),
            borderColor: Color(0xFFFECACA),
            isUrgent: true,
          );
        } else if (normalizedExplicit == 'closing_soon') {
          return const ComputedStatus(
            label: 'Closing Soon',
            foregroundColor: Color(0xFFD97706),
            backgroundColor: Color(0xFFFFFBEB),
            borderColor: Color(0xFFFDE68A),
            isUrgent: true,
          );
        } else if (normalizedExplicit == 'open' ||
            normalizedExplicit == 'live') {
          return const ComputedStatus(
            label: 'Open',
            foregroundColor: Color(0xFF059669),
            backgroundColor: Color(0xFFECFDF5),
            borderColor: Color(0xFFA7F3D0),
          );
        } else if (normalizedExplicit == 'upcoming') {
          return const ComputedStatus(
            label: 'Upcoming',
            foregroundColor: Color(0xFF1D4ED8),
            backgroundColor: Color(0xFFEFF6FF),
            borderColor: Color(0xFFBFDBFE),
          );
        }
      }

      if (lastDate != null) {
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final difference = lastDay.difference(today).inDays;

        if (difference < 0) {
          return const ComputedStatus(
            label: 'Closed',
            foregroundColor: Color(0xFF64748B),
            backgroundColor: Color(0xFFF1F5F9),
            borderColor: Color(0xFFCBD5E1),
          );
        } else if (difference == 0) {
          return const ComputedStatus(
            label: 'Closing Today',
            foregroundColor: Color(0xFFDC2626),
            backgroundColor: Color(0xFFFEF2F2),
            borderColor: Color(0xFFFECACA),
            isUrgent: true,
          );
        } else if (difference <= 3) {
          return ComputedStatus(
            label: difference == 1 ? '1 Day Left' : '$difference Days Left',
            foregroundColor: const Color(0xFFD97706),
            backgroundColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            isUrgent: true,
          );
        }
      }

      if (startDate != null) {
        final startDay =
            DateTime(startDate.year, startDate.month, startDate.day);
        if (startDay.isAfter(today)) {
          return const ComputedStatus(
            label: 'Upcoming',
            foregroundColor: Color(0xFF1D4ED8),
            backgroundColor: Color(0xFFEFF6FF),
            borderColor: Color(0xFFBFDBFE),
          );
        }
      }

      return const ComputedStatus(
        label: 'Open',
        foregroundColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    // 2. Admit Cards
    if (contentType == 'admit_card') {
      final normalized = (explicitStatus ?? '').toLowerCase().trim();
      if (normalized == 'upcoming') {
        return const ComputedStatus(
          label: 'Upcoming',
          foregroundColor: Color(0xFF2563EB),
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
        );
      }
      return const ComputedStatus(
        label: 'Available',
        foregroundColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    // 3. Results
    if (contentType == 'result') {
      final normalized = (explicitStatus ?? '').toLowerCase().trim();
      if (normalized == 'upcoming') {
        return const ComputedStatus(
          label: 'Upcoming',
          foregroundColor: Color(0xFF2563EB),
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
        );
      }
      return const ComputedStatus(
        label: 'Declared',
        foregroundColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    // 4. Answer Keys
    if (contentType == 'answer_key') {
      final normalized = (explicitStatus ?? '').toLowerCase().trim();
      if (normalized.contains('objection')) {
        return const ComputedStatus(
          label: 'Objection Open',
          foregroundColor: Color(0xFFD97706),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          isUrgent: true,
        );
      }
      if (normalized == 'closed') {
        return const ComputedStatus(
          label: 'Closed',
          foregroundColor: Color(0xFF64748B),
          backgroundColor: Color(0xFFF1F5F9),
          borderColor: Color(0xFFCBD5E1),
        );
      }
      return const ComputedStatus(
        label: 'Released',
        foregroundColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    // 5. Syllabus
    if (contentType == 'syllabus') {
      final normalized = (explicitStatus ?? '').toLowerCase().trim();
      if (normalized == 'updated') {
        return const ComputedStatus(
          label: 'Updated',
          foregroundColor: Color(0xFF2563EB),
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
        );
      }
      return const ComputedStatus(
        label: 'Available',
        foregroundColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
      );
    }

    // 6. Articles / Guides
    return const ComputedStatus(
      label: 'Published',
      foregroundColor: Color(0xFF0F172A),
      backgroundColor: Color(0xFFF1F5F9),
      borderColor: Color(0xFFE2E8F0),
    );
  }
}
