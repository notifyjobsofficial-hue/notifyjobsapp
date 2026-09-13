import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/admob_service.dart';
import 'nj_button.dart';

/// Premium Rewarded Ad Confirmation & Unlock Bottom Sheet (Specification 43–46 & 129)
class NjRewardSheet extends StatefulWidget {
  final String title;
  final String promptMessage;
  final String buttonText;
  final VoidCallback onRewardUnlocked;

  const NjRewardSheet({
    super.key,
    this.title = 'Unlock Official Notification',
    this.promptMessage =
        'Watch a short ad to open the official notification PDF.',
    this.buttonText = 'Watch Ad',
    required this.onRewardUnlocked,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? promptMessage,
    String? buttonText,
    required VoidCallback onRewardUnlocked,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NjRewardSheet(
        title: title ?? 'Unlock Official Notification',
        promptMessage: promptMessage ??
            'Watch a short ad to open the official notification PDF.',
        buttonText: buttonText ?? 'Watch Ad',
        onRewardUnlocked: onRewardUnlocked,
      ),
    );
  }

  @override
  State<NjRewardSheet> createState() => _NjRewardSheetState();
}

class _NjRewardSheetState extends State<NjRewardSheet> {
  final AdMobService _adService = AdMobService();
  RewardState _state = RewardState.idle;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Preload rewarded ad
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() {
      _error = null;
    });

    await _adService.loadRewardedAd(
      onStateChanged: (state) {
        if (mounted) {
          setState(() {
            _state = state;
            if (state == RewardState.failed) {
              _error = _adService.errorMessage ?? 'Ad unavailable right now.';
            }
          });
        }
      },
    );
  }

  Future<void> _onWatchAd() async {
    // Prevent double taps (Specification 44)
    if (_state == RewardState.loading || _state == RewardState.showing) return;

    if (_state == RewardState.ready) {
      await _adService.showRewardedAd(
        onStateChanged: (state) {
          if (mounted) {
            setState(() {
              _state = state;
              if (state == RewardState.failed) {
                _error = _adService.errorMessage;
              }
            });
          }
        },
        onUserEarnedReward: () {
          HapticFeedback.heavyImpact();
          if (mounted) {
            Navigator.pop(context);
            widget.onRewardUnlocked();
          }
        },
      );
    } else {
      // Not ready yet, retry loading
      await _loadAd();
    }
  }

  @override
  void dispose() {
    _adService.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Icon Badge
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              widget.title,
              style: AppTypography.sectionHeading.copyWith(
                fontSize: 17,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Prompt Message
            Text(
              widget.promptMessage,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Error notice if ad failed
            if (_error != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _error!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: NjButton(
                    label: 'Cancel',
                    variant: NjButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NjButton(
                    label: _state == RewardState.failed
                        ? 'Retry Ad'
                        : widget.buttonText,
                    variant: NjButtonVariant.primary,
                    isLoading: _state == RewardState.loading ||
                        _state == RewardState.showing,
                    icon: const Icon(Icons.play_circle_outline,
                        size: 18, color: Colors.white),
                    onPressed:
                        _state == RewardState.failed ? _loadAd : _onWatchAd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
