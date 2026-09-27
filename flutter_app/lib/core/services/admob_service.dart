import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

/// Central Singleton AdMob Service for Notify Jobs (Specification Part 12)
class AdMobService {
  AdMobService._internal();
  static final AdMobService instance = AdMobService._internal();
  factory AdMobService() => instance;

  RewardedAd? _cachedRewardedAd;
  bool _isLoading = false;
  bool _isShowing = false;
  DateTime? _lastRewardEarnedAt;
  String? _customAdUnitId;
  bool _testMode = false;

  bool get isAdAvailable => _cachedRewardedAd != null;
  bool get isLoading => _isLoading;
  bool get isShowing => _isShowing;

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Configure custom ad unit ID or test mode from Admin settings
  void configure({String? adUnitId, bool testMode = false}) {
    if (adUnitId != null && adUnitId.trim().isNotEmpty) {
      _customAdUnitId = adUnitId.trim();
    }
    _testMode = testMode;
  }

  /// Get effective ad unit ID respecting testMode and safety isolation
  String get effectiveAdUnitId {
    if (_testMode || !kReleaseMode) {
      return AdMobConfig.testRewardedAdUnitId;
    }
    if (_customAdUnitId != null && _customAdUnitId!.isNotEmpty) {
      return _customAdUnitId!;
    }
    return AdMobConfig.rewardedAdUnitId;
  }

  /// Check whether cooldown is active (Part 11)
  bool isCooldownActive(int cooldownMinutes) {
    if (_lastRewardEarnedAt == null) return false;
    final diff = DateTime.now().difference(_lastRewardEarnedAt!).inMinutes;
    return diff < cooldownMinutes;
  }

  /// Record timestamp when user earns a reward
  void recordCooldown() {
    _lastRewardEarnedAt = DateTime.now();
  }

  /// Reset cooldown (useful for unit testing or admin reset)
  void resetCooldown() {
    _lastRewardEarnedAt = null;
  }

  /// Preload and cache a rewarded ad instance
  Future<bool> preloadRewardedAd() async {
    if (_cachedRewardedAd != null || _isLoading || _isShowing) {
      return _cachedRewardedAd != null;
    }

    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: effectiveAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _cachedRewardedAd = ad;
            _isLoading = false;
            debugPrint('[AdMobService] Rewarded ad loaded and cached.');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _cachedRewardedAd = null;
            _isLoading = false;
            debugPrint('[AdMobService] Rewarded ad failed to load: $error');
          },
        ),
      );
      return true;
    } catch (e) {
      _cachedRewardedAd = null;
      _isLoading = false;
      debugPrint('[AdMobService] Exception during preload: $e');
      return false;
    }
  }

  /// Show the cached rewarded ad with full callback handling (Part 10)
  Future<void> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissedEarly,
    VoidCallback? onAdDismissedAfterReward,
    Function(String error)? onAdFailedToShow,
  }) async {
    // Prevent double taps (Part 12)
    if (_isShowing) return;

    if (_cachedRewardedAd == null) {
      // Try one immediate load if not already ready
      _isLoading = true;
      try {
        await RewardedAd.load(
          adUnitId: effectiveAdUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              _cachedRewardedAd = ad;
              _isLoading = false;
              _presentAd(
                ad,
                onUserEarnedReward: onUserEarnedReward,
                onAdDismissedEarly: onAdDismissedEarly,
                onAdDismissedAfterReward: onAdDismissedAfterReward,
                onAdFailedToShow: onAdFailedToShow,
              );
            },
            onAdFailedToLoad: (LoadAdError error) {
              _cachedRewardedAd = null;
              _isLoading = false;
              onAdFailedToShow?.call(error.message);
            },
          ),
        );
      } catch (e) {
        _isLoading = false;
        onAdFailedToShow?.call(e.toString());
      }
      return;
    }

    final adToPresent = _cachedRewardedAd!;
    _cachedRewardedAd = null; // Consume cached instance
    _presentAd(
      adToPresent,
      onUserEarnedReward: onUserEarnedReward,
      onAdDismissedEarly: onAdDismissedEarly,
      onAdDismissedAfterReward: onAdDismissedAfterReward,
      onAdFailedToShow: onAdFailedToShow,
    );
  }

  void _presentAd(
    RewardedAd ad, {
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissedEarly,
    VoidCallback? onAdDismissedAfterReward,
    Function(String error)? onAdFailedToShow,
  }) {
    _isShowing = true;
    bool rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('[AdMobService] Rewarded ad presented full screen.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint(
            '[AdMobService] Rewarded ad dismissed. Reward earned: $rewardEarned');
        ad.dispose();
        _isShowing = false;
        // Background reload immediately for next time
        preloadRewardedAd();
        if (rewardEarned) {
          if (onAdDismissedAfterReward != null) {
            onAdDismissedAfterReward();
          }
        } else {
          onAdDismissedEarly?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('[AdMobService] Rewarded ad failed to show: $error');
        ad.dispose();
        _isShowing = false;
        preloadRewardedAd();
        onAdFailedToShow?.call(error.message);
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
            '[AdMobService] User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
        recordCooldown();
        onUserEarnedReward();
      },
    );
  }
}
