import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

/// Explicit State Machine for Rewarded Ads (Specification 44)
enum RewardState {
  idle,
  loading,
  ready,
  showing,
  rewardEarned,
  openingLink,
  failed,
}

/// Rewarded Ad Manager for Notify Jobs
class AdMobService {
  RewardedAd? _rewardedAd;
  RewardState _state = RewardState.idle;
  String? _errorMessage;

  RewardState get state => _state;
  String? get errorMessage => _errorMessage;

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Load a rewarded ad
  Future<bool> loadRewardedAd({
    required Function(RewardState state) onStateChanged,
  }) async {
    if (_state == RewardState.loading || _state == RewardState.showing) {
      return false;
    }

    _state = RewardState.loading;
    _errorMessage = null;
    onStateChanged(_state);

    try {
      await RewardedAd.load(
        adUnitId: AdMobConfig.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _state = RewardState.ready;
            onStateChanged(_state);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _state = RewardState.failed;
            _errorMessage = 'Ad unavailable right now. (Code ${error.code})';
            onStateChanged(_state);
          },
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Exception while loading RewardedAd: $e');
      _state = RewardState.failed;
      _errorMessage = 'Could not load advertisement. Please check connection.';
      onStateChanged(_state);
      return false;
    }
  }

  /// Show the loaded rewarded ad with callbacks (Specification 44, 45, 46)
  Future<void> showRewardedAd({
    required Function(RewardState state) onStateChanged,
    required VoidCallback onUserEarnedReward,
  }) async {
    if (_state != RewardState.ready || _rewardedAd == null) {
      _state = RewardState.failed;
      _errorMessage = 'Ad is not ready to display.';
      onStateChanged(_state);
      return;
    }

    _state = RewardState.showing;
    onStateChanged(_state);

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        if (_state != RewardState.rewardEarned) {
          _state = RewardState.idle;
          onStateChanged(_state);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _state = RewardState.failed;
        _errorMessage = 'Failed to display video. Please try again.';
        onStateChanged(_state);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        _state = RewardState.rewardEarned;
        onStateChanged(_state);
        onUserEarnedReward();
      },
    );
  }

  void reset() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _state = RewardState.idle;
    _errorMessage = null;
  }
}
