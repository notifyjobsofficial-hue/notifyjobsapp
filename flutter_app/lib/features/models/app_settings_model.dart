/// Remote App Settings Model (Specification 80)
class AppSettingsModel {
  final String appTitle;
  final String tagline;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String minimumAppVersion;
  final String latestAppVersion;
  final String forceUpdateUrl;

  final String supportEmail;
  final String supportWebsite;

  final String whatsappUrl;
  final bool whatsappEnabled;
  final String telegramUrl;
  final bool telegramEnabled;
  final String youtubeUrl;
  final bool youtubeEnabled;
  final String facebookUrl;
  final bool facebookEnabled;
  final String instagramUrl;
  final bool instagramEnabled;
  final String xUrl;
  final bool xEnabled;

  final String privacyUrl;
  final String termsUrl;
  final String disclaimerUrl;
  final String contactUrl;

  final bool rewardedAdsEnabled;
  final bool rewardNotificationEnabled;
  final int rewardUnlockMinutes;
  final String rewardPromptText;
  final String rewardButtonText;

  final String shareBaseUrl;
  final String playStoreUrl;
  final String disclaimer;

  const AppSettingsModel({
    this.appTitle = 'Notify Jobs',
    this.tagline = 'Government Jobs. Results. Admit Cards. One App.',
    this.maintenanceMode = false,
    this.maintenanceMessage =
        'We are upgrading our servers to serve you better. We will be back online shortly!',
    this.minimumAppVersion = '1.0.0',
    this.latestAppVersion = '1.0.0',
    this.forceUpdateUrl =
        'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
    this.supportEmail = 'support@notifyjobs.in',
    this.supportWebsite = 'https://notifyjobs.in',
    this.whatsappUrl = 'https://whatsapp.com/channel/0029VaNotifyJobs',
    this.whatsappEnabled = true,
    this.telegramUrl = 'https://t.me/notifyjobs',
    this.telegramEnabled = true,
    this.youtubeUrl = 'https://youtube.com/@notifyjobs',
    this.youtubeEnabled = true,
    this.facebookUrl = 'https://facebook.com/notifyjobs',
    this.facebookEnabled = false,
    this.instagramUrl = 'https://instagram.com/notifyjobs',
    this.instagramEnabled = true,
    this.xUrl = 'https://x.com/notifyjobs',
    this.xEnabled = true,
    this.privacyUrl = 'https://notifyjobs.in/privacy',
    this.termsUrl = 'https://notifyjobs.in/terms',
    this.disclaimerUrl = 'https://notifyjobs.in/disclaimer',
    this.contactUrl = 'https://notifyjobs.in/contact',
    this.rewardedAdsEnabled = true,
    this.rewardNotificationEnabled = true,
    this.rewardUnlockMinutes = 30,
    this.rewardPromptText =
        'Watch a short ad to open the official notification.',
    this.rewardButtonText = 'Watch Ad',
    this.shareBaseUrl = 'https://notifyjobs.in/job',
    this.playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
    this.disclaimer =
        'Notify Jobs is an independent informational platform and is not affiliated with any government department. Users should verify recruitment information from the official source before applying.',
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      AppSettingsModel.fromMap(json);

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      appTitle: map['appTitle']?.toString() ?? 'Notify Jobs',
      tagline: map['tagline']?.toString() ??
          'Government Jobs. Results. Admit Cards. One App.',
      maintenanceMode: map['maintenanceMode'] == true,
      maintenanceMessage: map['maintenanceMessage']?.toString() ??
          'We are upgrading our servers to serve you better. We will be back online shortly!',
      minimumAppVersion: map['minimumAppVersion']?.toString() ?? '1.0.0',
      latestAppVersion: map['latestAppVersion']?.toString() ?? '1.0.0',
      forceUpdateUrl: map['forceUpdateUrl']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
      supportEmail: map['supportEmail']?.toString() ?? 'support@notifyjobs.in',
      supportWebsite:
          map['supportWebsite']?.toString() ?? 'https://notifyjobs.in',
      whatsappUrl: map['whatsappUrl']?.toString() ?? '',
      whatsappEnabled: map['whatsappEnabled'] != false,
      telegramUrl: map['telegramUrl']?.toString() ?? '',
      telegramEnabled: map['telegramEnabled'] != false,
      youtubeUrl: map['youtubeUrl']?.toString() ?? '',
      youtubeEnabled: map['youtubeEnabled'] != false,
      facebookUrl: map['facebookUrl']?.toString() ?? '',
      facebookEnabled: map['facebookEnabled'] == true,
      instagramUrl: map['instagramUrl']?.toString() ?? '',
      instagramEnabled: map['instagramEnabled'] != false,
      xUrl: map['xUrl']?.toString() ?? '',
      xEnabled: map['xEnabled'] != false,
      privacyUrl:
          map['privacyUrl']?.toString() ?? 'https://notifyjobs.in/privacy',
      termsUrl: map['termsUrl']?.toString() ?? 'https://notifyjobs.in/terms',
      disclaimerUrl: map['disclaimerUrl']?.toString() ??
          'https://notifyjobs.in/disclaimer',
      contactUrl:
          map['contactUrl']?.toString() ?? 'https://notifyjobs.in/contact',
      rewardedAdsEnabled: map['rewardedAdsEnabled'] != false,
      rewardNotificationEnabled: map['rewardNotificationEnabled'] != false,
      rewardUnlockMinutes:
          int.tryParse(map['rewardUnlockMinutes']?.toString() ?? '30') ?? 30,
      rewardPromptText: map['rewardPromptText']?.toString() ??
          'Watch a short ad to open the official notification.',
      rewardButtonText: map['rewardButtonText']?.toString() ?? 'Watch Ad',
      shareBaseUrl:
          map['shareBaseUrl']?.toString() ?? 'https://notifyjobs.in/job',
      playStoreUrl: map['playStoreUrl']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
      disclaimer: map['disclaimer']?.toString() ??
          'Notify Jobs is an independent informational platform and is not affiliated with any government department. Users should verify recruitment information from the official source before applying.',
    );
  }
}
