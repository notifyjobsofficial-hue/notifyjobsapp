import 'package:intl/intl.dart';

/// Centralized Text and Date Normalization Utilities for Notify Jobs
class NormalizationUtils {
  NormalizationUtils._();

  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  /// Formats age text cleanly and prevents unit duplication like "Years Years"
  static String formatYears(dynamic input) {
    if (input == null) return '';
    final raw = input.toString().trim();
    if (raw.isEmpty) return '';

    // Strip existing duplicate "years", "year", "yrs", "yr" case-insensitively
    final cleaned = raw
        .replaceAll(
            RegExp(r'\s*(years|year|yrs|yr)\b', caseSensitive: false), '')
        .trim();

    if (cleaned.isEmpty) return '';
    return '$cleaned Years';
  }

  /// Formats age limit from min and max age integers or strings
  static String formatAgeRange(dynamic minAge, dynamic maxAge) {
    if (minAge == null && maxAge == null) return 'As per rules';

    final minStr = minAge != null
        ? minAge.toString().replaceAll(RegExp(r'[^0-9]'), '')
        : '';
    final maxStr = maxAge != null
        ? maxAge.toString().replaceAll(RegExp(r'[^0-9]'), '')
        : '';

    if (minStr.isNotEmpty && maxStr.isNotEmpty) {
      return '$minStr - $maxStr Years';
    } else if (maxStr.isNotEmpty) {
      return 'Max $maxStr Years';
    } else if (minStr.isNotEmpty) {
      return 'Min $minStr Years';
    }
    return 'As per rules';
  }

  /// Formats a DateTime or ISO-8601 string into standard user-facing format (e.g. 05 Oct 2026)
  static String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return _displayDateFormat.format(date);
    }
    if (date is String) {
      final trimmed = date.trim();
      if (trimmed.isEmpty) return '';
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return _displayDateFormat.format(parsed);
      }
      return trimmed;
    }
    return date.toString();
  }

  /// Formats a date in short form (e.g. 05 Oct)
  static String formatShortDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return _shortDateFormat.format(date);
    }
    if (date is String) {
      final trimmed = date.trim();
      if (trimmed.isEmpty) return '';
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return _shortDateFormat.format(parsed);
      }
      return trimmed;
    }
    return date.toString();
  }

  /// Cleans and formats important dates and label pairs to strictly prevent
  /// collisions like "Physical Endurance TestNovember 2026"
  static String formatImportantDateLabel(String label, dynamic date) {
    final cleanLabel = label.trim();
    final cleanDate = formatDate(date);

    if (cleanLabel.isEmpty) return cleanDate;
    if (cleanDate.isEmpty) return cleanLabel;

    return '$cleanLabel\n$cleanDate';
  }

  /// Normalizes vacancy counts (e.g. 418 -> "418 Posts" or "Various")
  static String formatVacancies(dynamic vacancies) {
    if (vacancies == null) return 'Various';
    final raw = vacancies.toString().trim();
    if (raw.isEmpty || raw == '0') return 'Various';

    final cleaned = raw
        .replaceAll(
            RegExp(r'\s*(posts|post|vacancies|vacancy)\b',
                caseSensitive: false),
            '')
        .trim();

    final count = int.tryParse(cleaned);
    if (count != null) {
      final formatted = NumberFormat.decimalPattern('en_IN').format(count);
      return count == 1 ? '$formatted Post' : '$formatted Posts';
    }

    return raw.toLowerCase().contains('post') ? raw : '$raw Posts';
  }
}
