import 'package:share_plus/share_plus.dart';
import '../../features/models/app_settings_model.dart';
import '../../features/models/content_model.dart';

/// Centralized Smart Share Service for Notify Jobs
class ShareService {
  ShareService._();

  static const String defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.notifyjobs.app';
  static const String defaultWebsiteUrl = 'https://notifyjobs.in';

  /// Validates whether a given string is a well-formed HTTPS URL
  static bool isValidHttpsUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme.toLowerCase() == 'https' ||
            uri.scheme.toLowerCase() == 'http') &&
        uri.host.isNotEmpty;
  }

  /// Builds the web detail URL using the content slug.
  /// Strictly avoids sharing raw Firestore IDs.
  static String buildWebJobUrl({
    required ContentModel content,
    required String basePortalUrl,
  }) {
    final cleanBase = basePortalUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final cleanSlug = content.slug.trim().replaceAll(RegExp(r'^/+'), '');

    if (cleanSlug.isEmpty) {
      return cleanBase;
    }

    // If the base URL already has the path segment
    if (cleanBase.endsWith('/job') ||
        cleanBase.endsWith('/jobs') ||
        cleanBase.endsWith('/article') ||
        cleanBase.endsWith('/articles')) {
      return '$cleanBase/$cleanSlug';
    }

    // Domain root only: add type-aware path
    final typePath = content.contentType == 'article' ? 'articles' : 'jobs';
    return '$cleanBase/$typePath/$cleanSlug';
  }

  /// Resolves the optimal URL according to Admin and Post settings:
  /// Mode: PLAY_STORE | WEBSITE | SMART | CUSTOM_URL
  static String resolveShareUrl({
    required ContentModel content,
    AppSettingsModel? settings,
    String? configuredBaseUrl,
    String? playStoreUrl,
    String? shareTargetMode,
  }) {
    final effectivePlayStore = (playStoreUrl?.trim().isNotEmpty == true)
        ? playStoreUrl!.trim()
        : ((settings?.playStoreUrl.trim().isNotEmpty == true)
            ? settings!.playStoreUrl.trim()
            : defaultPlayStoreUrl);

    final String? effectiveBaseUrl =
        (configuredBaseUrl?.trim().isNotEmpty == true)
            ? configuredBaseUrl!.trim()
            : ((settings?.websiteUrl.trim().isNotEmpty == true)
                ? settings!.websiteUrl.trim()
                : ((settings?.shareBaseUrl.trim().isNotEmpty == true)
                    ? settings!.shareBaseUrl.trim()
                    : null));

    final effectiveMode =
        (content.shareTargetModeOverride?.isNotEmpty == true &&
                content.shareTargetModeOverride != 'GLOBAL')
            ? content.shareTargetModeOverride!
            : (shareTargetMode?.isNotEmpty == true
                ? shareTargetMode!
                : (settings?.shareTargetMode ?? 'SMART'));

    switch (effectiveMode) {
      case 'PLAY_STORE':
        return effectivePlayStore;

      case 'WEBSITE':
        return buildWebJobUrl(
          content: content,
          basePortalUrl: effectiveBaseUrl ?? defaultWebsiteUrl,
        );

      case 'CUSTOM_URL':
        if (isValidHttpsUrl(content.customShareUrl)) {
          return content.customShareUrl!.trim();
        }
        return buildWebJobUrl(
          content: content,
          basePortalUrl: effectiveBaseUrl ?? defaultWebsiteUrl,
        );

      case 'SMART':
      default:
        // Tier 1: If web portal base URL is configured and slug exists
        if (effectiveBaseUrl != null &&
            effectiveBaseUrl.isNotEmpty &&
            content.slug.trim().isNotEmpty) {
          return buildWebJobUrl(
            content: content,
            basePortalUrl: effectiveBaseUrl,
          );
        }

        // Tier 2: Official Apply or Notification URL if valid
        if (isValidHttpsUrl(content.applyUrl)) {
          return content.applyUrl!.trim();
        }
        if (isValidHttpsUrl(content.sourceUrl)) {
          return content.sourceUrl!.trim();
        }

        // Tier 3: Google Play Store URL
        return effectivePlayStore;
    }
  }

  /// Formats context-aware share message without nulls or N/A
  static String formatShareMessage({
    required ContentModel content,
    AppSettingsModel? settings,
    String? configuredBaseUrl,
    String? playStoreUrl,
    String? shareTargetMode,
    String? messageTemplate,
  }) {
    final shareUrl = resolveShareUrl(
      content: content,
      settings: settings,
      configuredBaseUrl: configuredBaseUrl,
      playStoreUrl: playStoreUrl,
      shareTargetMode: shareTargetMode,
    );

    final effectivePlayStore = (playStoreUrl?.trim().isNotEmpty == true)
        ? playStoreUrl!.trim()
        : ((settings?.playStoreUrl.trim().isNotEmpty == true)
            ? settings!.playStoreUrl.trim()
            : defaultPlayStoreUrl);

    // If custom share text is explicitly defined on the content item
    if (content.customShareText != null &&
        content.customShareText!.trim().isNotEmpty) {
      return content.customShareText!
          .replaceAll('{title}', content.title)
          .replaceAll(
              '{organization}',
              content.organization.isNotEmpty
                  ? content.organization
                  : (content.companyName ?? ''))
          .replaceAll('{vacancies}', content.displayVacancies)
          .replaceAll('{lastDate}', content.displayLastDate)
          .replaceAll('{shareUrl}', shareUrl)
          .replaceAll('{playStoreUrl}', effectivePlayStore)
          .trim();
    }

    // Default clean template
    final template = messageTemplate ??
        (settings?.shareMessageTemplate.isNotEmpty == true
            ? settings!.shareMessageTemplate
            : '');

    if (template.isNotEmpty) {
      var msg = template
          .replaceAll('{title}', content.title)
          .replaceAll(
              '{organization}',
              content.organization.isNotEmpty
                  ? content.organization
                  : (content.companyName ?? 'Govt Organization'))
          .replaceAll('{vacancies}', content.displayVacancies)
          .replaceAll('{lastDate}', content.displayLastDate)
          .replaceAll('{shareUrl}', shareUrl)
          .replaceAll('{playStoreUrl}', effectivePlayStore);

      // Clean multiple consecutive blank lines
      msg = msg.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      return msg.trim();
    }

    // High quality standard structured format
    final buffer = StringBuffer();
    buffer.writeln('📢 ${content.title}');

    final org = content.organization.isNotEmpty
        ? content.organization
        : (content.companyName ?? '');
    if (org.isNotEmpty) {
      buffer.writeln('🏛️ $org');
    }

    if (content.vacancies.isNotEmpty && content.displayVacancies != '0') {
      buffer.writeln('👥 Vacancies: ${content.displayVacancies}');
    }

    if (content.applicationLastDate != null &&
        content.applicationLastDate!.isNotEmpty) {
      buffer.writeln('⏳ Last Date: ${content.displayLastDate}');
    }

    if (shareUrl.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('👉 View Details & Apply:');
      buffer.writeln(shareUrl);
    }

    buffer.writeln();
    buffer.writeln('📱 Download Notify Jobs App for Instant Sarkari Alerts:');
    buffer.writeln(effectivePlayStore);

    return buffer.toString().trim();
  }

  /// Opens native platform share dialog
  static Future<void> shareContent({
    required ContentModel content,
    AppSettingsModel? settings,
    String? configuredBaseUrl,
    String? playStoreUrl,
  }) async {
    final text = formatShareMessage(
      content: content,
      settings: settings,
      configuredBaseUrl: configuredBaseUrl,
      playStoreUrl: playStoreUrl,
    );
    await Share.share(text, subject: content.title);
  }
}
