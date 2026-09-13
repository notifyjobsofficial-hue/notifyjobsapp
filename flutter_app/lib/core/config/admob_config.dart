import 'package:flutter/foundation.dart';

/// AdMob Configuration & Safety Isolation (Specification 9 & 10)
class AdMobConfig {
  AdMobConfig._();

  /// Official Google Android Rewarded Test Unit ID for development
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  /// Production Placeholders to be populated before Google Play Store release
  static const String productionRewardedAdUnitId =
      'REWARDED_NOTIFICATION_AD_UNIT_ID';

  /// Returns the appropriate ad unit ID based on environment safety check
  static String get rewardedAdUnitId {
    // Safety guarantee: Always use Google test ad ID unless in release mode AND a valid production ID is set
    if (kReleaseMode &&
        productionRewardedAdUnitId != 'REWARDED_NOTIFICATION_AD_UNIT_ID' &&
        productionRewardedAdUnitId.isNotEmpty) {
      return productionRewardedAdUnitId;
    }
    // Strictly return official test unit for development
    return testRewardedAdUnitId;
  }
}
