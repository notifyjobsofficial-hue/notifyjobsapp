import 'package:share_plus/share_plus.dart';
import '../../features/models/content_model.dart';

/// Centralized 4-tier Share Service for Notify Jobs
class ShareService {
  ShareService._();

  /// Resolves the optimal URL with 4-tier fallback:
  /// 1. Content deep-link via configured Web Portal (`shareBaseUrl + slug`)
  /// 2. Official apply or source URL
  /// 3. Google Play Store URL
  /// 4. Default portal link
  static String resolveShareUrl({
    required ContentModel content,
    String? configuredBaseUrl,
    String? playStoreUrl,
  }) {
    // Tier 1: Configured Web Portal share URL with slug
    if (configuredBaseUrl != null && configuredBaseUrl.trim().isNotEmpty) {
      final base = configuredBaseUrl.trim().endsWith('/')
          ? configuredBaseUrl.trim()
          : '${configuredBaseUrl.trim()}/';
      return '$base${content.slug}';
    }

    // Tier 2: Official Apply or Notification URL
    if (content.applyUrl != null && content.applyUrl!.trim().isNotEmpty) {
      return content.applyUrl!.trim();
    }
    if (content.sourceUrl != null && content.sourceUrl!.trim().isNotEmpty) {
      return content.sourceUrl!.trim();
    }

    // Tier 3: Google Play Store URL
    if (playStoreUrl != null && playStoreUrl.trim().isNotEmpty) {
      return playStoreUrl.trim();
    }

    // Tier 4: Fallback Play Store link
    return 'https://play.google.com/store/apps/details?id=com.notifyjobs.app';
  }

  /// Formats context-aware share message
  static String formatShareMessage({
    required ContentModel content,
    String? configuredBaseUrl,
    String? playStoreUrl,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📢 ${content.title}');

    if (content.organization.isNotEmpty) {
      buffer.writeln('🏛️ ${content.organization}');
    }

    if (content.vacancies.isNotEmpty) {
      buffer.writeln('👥 Vacancies: ${content.displayVacancies}');
    }

    if (content.applicationLastDate != null &&
        content.applicationLastDate!.isNotEmpty) {
      buffer.writeln('⏳ Last Date: ${content.displayLastDate}');
    }

    final url = resolveShareUrl(
      content: content,
      configuredBaseUrl: configuredBaseUrl,
      playStoreUrl: playStoreUrl,
    );

    if (url.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('👉 View Details & Apply:');
      buffer.writeln(url);
    }

    buffer.writeln();
    buffer.writeln('📱 Download Notify Jobs App for Instant Sarkari Alerts.');

    return buffer.toString().trim();
  }

  /// Opens native platform share dialog
  static Future<void> shareContent({
    required ContentModel content,
    String? configuredBaseUrl,
    String? playStoreUrl,
  }) async {
    final text = formatShareMessage(
      content: content,
      configuredBaseUrl: configuredBaseUrl,
      playStoreUrl: playStoreUrl,
    );
    await Share.share(text, subject: content.title);
  }
}
