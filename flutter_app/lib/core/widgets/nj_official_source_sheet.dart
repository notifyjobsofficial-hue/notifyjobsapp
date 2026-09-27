import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/admob_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/models/app_settings_model.dart';
import 'nj_button.dart';

enum OfficialSourceType {
  apply,
  notification,
  website,
}

/// Official Source Navigation Bottom Sheet with required Rewarded Ad flow
/// Gates optional external official redirects (Apply Online, Notification, Website).
/// All in-app job content remains 100% free and unblocked.
class NjOfficialSourceSheet extends StatefulWidget {
  final String url;
  final OfficialSourceType type;
  final VoidCallback onProceed;

  const NjOfficialSourceSheet({
    super.key,
    required this.url,
    required this.type,
    required this.onProceed,
  });

  /// Static entrypoint that evaluates settings and cooldown before opening the sheet.
  /// If ads are disabled or cooldown is active, it invokes [onProceed] immediately.
  static Future<void> show(
    BuildContext context, {
    required String url,
    required OfficialSourceType type,
    required AppSettingsModel appSettings,
    required VoidCallback onProceed,
  }) async {
    // 1. Check global ad settings
    if (!appSettings.adsEnabled || !appSettings.rewardedAdsEnabled) {
      onProceed();
      return;
    }

    // 2. Check per-action toggle
    bool isActionEnabled = false;
    switch (type) {
      case OfficialSourceType.apply:
        isActionEnabled = appSettings.applyRewardedEnabled;
        break;
      case OfficialSourceType.notification:
        isActionEnabled = appSettings.notificationDownloadRewardedEnabled;
        break;
      case OfficialSourceType.website:
        isActionEnabled = appSettings.officialWebsiteRewardedEnabled;
        break;
    }

    if (!isActionEnabled) {
      onProceed();
      return;
    }

    // 3. Check cooldown
    if (AdMobService.instance
        .isCooldownActive(appSettings.rewardedCooldownMinutes)) {
      onProceed();
      return;
    }

    // Configure AdMob ad unit if set in admin
    AdMobService.instance.configure(
      adUnitId: appSettings.rewardedAdUnitAndroid,
      testMode: appSettings.testMode,
    );

    // Preload in background
    AdMobService.instance.preloadRewardedAd();

    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NjOfficialSourceSheet(
        url: url,
        type: type,
        onProceed: onProceed,
      ),
    );
  }

  @override
  State<NjOfficialSourceSheet> createState() => _NjOfficialSourceSheetState();
}

class _NjOfficialSourceSheetState extends State<NjOfficialSourceSheet> {
  bool _isLoadingAd = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasProceeded = false;

  String _getActionSubtitle() {
    switch (widget.type) {
      case OfficialSourceType.apply:
        return 'Apply Online';
      case OfficialSourceType.notification:
        return 'Official Notification';
      case OfficialSourceType.website:
        return 'Official Website';
    }
  }

  bool _isTargetUrlValid(String url) {
    var cleaned = url.trim();
    if (cleaned.isEmpty) return false;
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'https://$cleaned';
    }
    final uri = Uri.tryParse(cleaned);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  Future<void> _watchAdAndContinue() async {
    if (_isLoadingAd) return; // double-tap protection

    // 1. Validate target HTTPS URL
    if (!_isTargetUrlValid(widget.url)) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Official destination link is unavailable or invalid.';
      });
      return;
    }

    setState(() {
      _isLoadingAd = true;
      _hasError = false;
      _errorMessage = null;
    });

    final adService = AdMobService.instance;

    // 2. Verify rewarded ad availability & 3. show rewarded ad
    await adService.showRewardedAd(
      // 4. Wait for successful reward callback
      onUserEarnedReward: () {
        debugPrint(
            '[NjOfficialSourceSheet] User earned reward for external redirect.');
      },
      // 5. Close ad & 6. Immediately open intended official destination & 7. start configured cooldown
      onAdDismissedAfterReward: () {
        if (!mounted) return;
        _proceedToDestination();
      },
      // Early close: If user closes before completion -> return to the same bottom sheet, do NOT open destination
      onAdDismissedEarly: () {
        debugPrint(
            '[NjOfficialSourceSheet] Ad dismissed early without completing reward.');
        if (!mounted) return;
        setState(() {
          _isLoadingAd = false;
          _hasError = false;
          _errorMessage = null;
        });
      },
      // Ad Failure: If rewarded ad fails to load or show -> do NOT open destination, show unavailable message
      onAdFailedToShow: (error) {
        debugPrint('[NjOfficialSourceSheet] Ad show failed: $error');
        if (!mounted) return;
        setState(() {
          _isLoadingAd = false;
          _hasError = true;
          _errorMessage =
              'Ad is currently unavailable. Please try again shortly.';
        });
      },
    );
  }

  void _proceedToDestination() {
    if (_hasProceeded) return;
    _hasProceeded = true;
    if (mounted) {
      Navigator.of(context).pop();
    }
    widget.onProceed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Icon + Title + Subtitle
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (_hasError ? AppColors.error : AppColors.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _hasError
                        ? Icons.error_outline_rounded
                        : Icons.open_in_browser_rounded,
                    color: _hasError ? AppColors.error : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue to Official Source',
                        style: AppTypography.sectionHeading.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getActionSubtitle(),
                        style: AppTypography.caption.copyWith(
                          color:
                              _hasError ? AppColors.error : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Message
            Text(
              _hasError
                  ? (_errorMessage ??
                      'Ad is currently unavailable. Please try again shortly.')
                  : 'Watch a short ad to continue to the official source.',
              style: AppTypography.body.copyWith(
                fontSize: 13.5,
                color: _hasError
                    ? (isDark ? const Color(0xFFFCA5A5) : AppColors.error)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // Primary Button: Retry or Watch Ad & Continue
            if (_hasError)
              NjButton(
                label: 'Retry',
                icon: const Icon(Icons.refresh_rounded,
                    size: 20, color: Colors.white),
                isLoading: _isLoadingAd,
                onPressed: _watchAdAndContinue,
              )
            else
              NjButton(
                label: 'Watch Ad & Continue',
                icon: const Icon(Icons.play_circle_outline_rounded,
                    size: 20, color: Colors.white),
                isLoading: _isLoadingAd,
                onPressed: _watchAdAndContinue,
              ),
            const SizedBox(height: 6),

            // Secondary Action: Cancel
            Center(
              child: TextButton(
                onPressed:
                    _isLoadingAd ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
