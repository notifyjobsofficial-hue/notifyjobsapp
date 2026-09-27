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

  final bool adsEnabled;
  final bool rewardedAdsEnabled;
  final bool supportRewardedEnabled;
  final bool applyRewardedEnabled;
  final bool notificationDownloadRewardedEnabled;
  final bool officialWebsiteRewardedEnabled;
  final bool allowSkipRewarded;
  final int rewardedCooldownMinutes;
  final String rewardedAdUnitAndroid;
  final bool testMode;

  final bool rewardNotificationEnabled;
  final int rewardUnlockMinutes;
  final String rewardPromptText;
  final String rewardButtonText;

  final String shareBaseUrl;
  final String playStoreUrl;
  final String disclaimer;

  // Announcement Banner (v1.1)
  final bool announcementEnabled;
  final String announcementType;
  final String announcementText;
  final String announcementUrl;
  final String announcementStartAt;
  final String announcementEndAt;
  final int announcementPriority;

  // Live Updates (v1.1)
  final bool liveUpdatesEnabled;
  final String liveUpdatesTitle;
  final int liveUpdatesMaxItems;
  final bool liveUpdatesAutoSlideEnabled;
  final int liveUpdatesAutoSlideSeconds;

  // Closing Soon (v1.1)
  final bool closingSoonEnabled;
  final String closingSoonTitle;
  final int closingSoonDaysThreshold;
  final int closingSoonMaxItems;

  // Popular This Week (v1.1)
  final bool popularEnabled;
  final String popularTitle;
  final int popularMaxItems;

  // Latest Jobs (v1.1)
  final bool latestJobsEnabled;
  final String latestJobsTitle;
  final int latestJobsMaxItems;

  // Quick Categories (v1.1)
  final bool quickCategoriesEnabled;
  final String quickCategoriesTitle;

  // Central Feature Flags (v1.1)
  final bool proPageEnabled;
  final bool supportPageEnabled;
  final bool notificationPreferencesEnabled;
  final bool socialSectionEnabled;

  // Dynamic Badges & Section Headings (v1.1)
  final int newBadgeDurationDays;
  final String andamanJobsTitle;
  final String andamanJobsSubtitle;
  final String importantUpdatesTitle;
  final String importantUpdatesSubtitle;
  final String articlesTitle;
  final String articlesSubtitle;

  // Merged Support & Ad-Free Settings (v1.1)
  final String supportPageHeading;
  final String supportPageSubtitle;
  final String adFreeProductId;
  final String adFreeProductLabel;
  final String adFreeProductDescription;
  final String thankYouMessage;

  // Predefined Ad Slots Configuration (v1.1)
  final Map<String, dynamic> adSlots;

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
    this.supportEmail = '',
    this.supportWebsite = '',
    this.whatsappUrl = '',
    this.whatsappEnabled = true,
    this.telegramUrl = '',
    this.telegramEnabled = true,
    this.youtubeUrl = '',
    this.youtubeEnabled = true,
    this.facebookUrl = '',
    this.facebookEnabled = false,
    this.instagramUrl = '',
    this.instagramEnabled = true,
    this.xUrl = '',
    this.xEnabled = true,
    this.privacyUrl = '',
    this.termsUrl = '',
    this.disclaimerUrl = '',
    this.contactUrl = '',
    this.adsEnabled = true,
    this.rewardedAdsEnabled = true,
    this.supportRewardedEnabled = true,
    this.applyRewardedEnabled = true,
    this.notificationDownloadRewardedEnabled = true,
    this.officialWebsiteRewardedEnabled = true,
    this.allowSkipRewarded = true,
    this.rewardedCooldownMinutes = 10,
    this.rewardedAdUnitAndroid = '',
    this.testMode = false,
    this.rewardNotificationEnabled = true,
    this.rewardUnlockMinutes = 30,
    this.rewardPromptText =
        'Watch a short ad to open the official notification.',
    this.rewardButtonText = 'Watch Ad',
    this.shareBaseUrl = '',
    this.playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
    this.disclaimer =
        'Notify Jobs is an independent informational platform and is not affiliated with any government department. Users should verify recruitment information from the official source before applying.',

    // Announcement Banner Defaults
    this.announcementEnabled = false,
    this.announcementType = 'New',
    this.announcementText = '',
    this.announcementUrl = '',
    this.announcementStartAt = '',
    this.announcementEndAt = '',
    this.announcementPriority = 1,

    // Live Updates Defaults
    this.liveUpdatesEnabled = true,
    this.liveUpdatesTitle = 'Live Updates',
    this.liveUpdatesMaxItems = 5,
    this.liveUpdatesAutoSlideEnabled = true,
    this.liveUpdatesAutoSlideSeconds = 4,

    // Closing Soon Defaults
    this.closingSoonEnabled = true,
    this.closingSoonTitle = 'Closing Soon',
    this.closingSoonDaysThreshold = 7,
    this.closingSoonMaxItems = 5,

    // Popular This Week Defaults
    this.popularEnabled = true,
    this.popularTitle = 'Popular This Week',
    this.popularMaxItems = 5,

    // Latest Jobs Defaults
    this.latestJobsEnabled = true,
    this.latestJobsTitle = 'Latest Jobs',
    this.latestJobsMaxItems = 6,

    // Quick Categories Defaults
    this.quickCategoriesEnabled = true,
    this.quickCategoriesTitle = 'Quick Categories',

    // Central Feature Flags Defaults
    this.proPageEnabled = false,
    this.supportPageEnabled = true,
    this.notificationPreferencesEnabled = true,
    this.socialSectionEnabled = true,

    // Dynamic Badges & Section Headings Defaults
    this.newBadgeDurationDays = 3,
    this.andamanJobsTitle = 'Andaman & Nicobar Vacancies',
    this.andamanJobsSubtitle = 'Island recruitment notifications',
    this.importantUpdatesTitle = 'Important Updates & Results',
    this.importantUpdatesSubtitle = 'Admit cards, results & answers',
    this.articlesTitle = 'Preparation & Career Guides',
    this.articlesSubtitle = 'Syllabus, guides and exam prep',

    // Merged Support & Ad-Free Settings Defaults
    this.supportPageHeading = 'Support Notify Jobs',
    this.supportPageSubtitle =
        'Keep recruitment alerts free, fast & independent for everyone.',
    this.adFreeProductId = 'notify_jobs_pro_lifetime',
    this.adFreeProductLabel = 'Ad-Free Experience (Lifetime)',
    this.adFreeProductDescription =
        'Browse all notifications, admit cards & results completely ad-free forever.',
    this.thankYouMessage =
        'Thank you for your generous support! Your ad-free experience is active.',

    // Predefined Ad Slots Defaults
    this.adSlots = const {},
  });

  /// Check whether announcement banner is active and within schedule window
  bool get isAnnouncementActive {
    if (!announcementEnabled || announcementText.trim().isEmpty) {
      return false;
    }
    final now = DateTime.now();
    if (announcementStartAt.isNotEmpty) {
      final start = DateTime.tryParse(announcementStartAt);
      if (start != null && now.isBefore(start)) return false;
    }
    if (announcementEndAt.isNotEmpty) {
      final end = DateTime.tryParse(announcementEndAt);
      if (end != null && now.isAfter(end)) return false;
    }
    return true;
  }

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
      supportEmail: map['supportEmail']?.toString() ?? '',
      supportWebsite: map['supportWebsite']?.toString() ?? '',
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
      privacyUrl: map['privacyUrl']?.toString() ?? '',
      termsUrl: map['termsUrl']?.toString() ?? '',
      disclaimerUrl: map['disclaimerUrl']?.toString() ?? '',
      contactUrl: map['contactUrl']?.toString() ?? '',
      adsEnabled: map['adsEnabled'] != false,
      rewardedAdsEnabled: map['rewardedAdsEnabled'] != false,
      supportRewardedEnabled: map['supportRewardedEnabled'] != false,
      applyRewardedEnabled: map['applyRewardedEnabled'] != false,
      notificationDownloadRewardedEnabled:
          map['notificationDownloadRewardedEnabled'] != false,
      officialWebsiteRewardedEnabled:
          map['officialWebsiteRewardedEnabled'] != false,
      allowSkipRewarded: map['allowSkipRewarded'] != false,
      rewardedCooldownMinutes:
          int.tryParse(map['rewardedCooldownMinutes']?.toString() ?? '10') ??
              10,
      rewardedAdUnitAndroid: map['rewardedAdUnitAndroid']?.toString() ?? '',
      testMode: map['testMode'] == true,
      rewardNotificationEnabled: map['rewardNotificationEnabled'] != false,
      rewardUnlockMinutes:
          int.tryParse(map['rewardUnlockMinutes']?.toString() ?? '30') ?? 30,
      rewardPromptText: map['rewardPromptText']?.toString() ??
          'Watch a short ad to open the official notification.',
      rewardButtonText: map['rewardButtonText']?.toString() ?? 'Watch Ad',
      shareBaseUrl: map['shareBaseUrl']?.toString() ?? '',
      playStoreUrl: map['playStoreUrl']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.notifyjobs.app',
      disclaimer: map['disclaimer']?.toString() ??
          'Notify Jobs is an independent informational platform and is not affiliated with any government department. Users should verify recruitment information from the official source before applying.',

      // Announcement Banner
      announcementEnabled: map['announcementEnabled'] == true,
      announcementType: map['announcementType']?.toString() ?? 'New',
      announcementText: map['announcementText']?.toString() ?? '',
      announcementUrl: map['announcementUrl']?.toString() ?? '',
      announcementStartAt: map['announcementStartAt']?.toString() ?? '',
      announcementEndAt: map['announcementEndAt']?.toString() ?? '',
      announcementPriority:
          int.tryParse(map['announcementPriority']?.toString() ?? '1') ?? 1,

      // Live Updates
      liveUpdatesEnabled: map['liveUpdatesEnabled'] != false,
      liveUpdatesTitle: map['liveUpdatesTitle']?.toString() ?? 'Live Updates',
      liveUpdatesMaxItems:
          int.tryParse(map['liveUpdatesMaxItems']?.toString() ?? '5') ?? 5,
      liveUpdatesAutoSlideEnabled: map['liveUpdatesAutoSlideEnabled'] != false,
      liveUpdatesAutoSlideSeconds:
          int.tryParse(map['liveUpdatesAutoSlideSeconds']?.toString() ?? '4') ??
              4,

      // Closing Soon
      closingSoonEnabled: map['closingSoonEnabled'] != false,
      closingSoonTitle: map['closingSoonTitle']?.toString() ?? 'Closing Soon',
      closingSoonDaysThreshold:
          int.tryParse(map['closingSoonDaysThreshold']?.toString() ?? '7') ?? 7,
      closingSoonMaxItems:
          int.tryParse(map['closingSoonMaxItems']?.toString() ?? '5') ?? 5,

      // Popular This Week
      popularEnabled: map['popularEnabled'] != false,
      popularTitle: map['popularTitle']?.toString() ?? 'Popular This Week',
      popularMaxItems:
          int.tryParse(map['popularMaxItems']?.toString() ?? '5') ?? 5,

      // Latest Jobs
      latestJobsEnabled: map['latestJobsEnabled'] != false,
      latestJobsTitle: map['latestJobsTitle']?.toString() ?? 'Latest Jobs',
      latestJobsMaxItems:
          int.tryParse(map['latestJobsMaxItems']?.toString() ?? '6') ?? 6,

      // Quick Categories
      quickCategoriesEnabled: map['quickCategoriesEnabled'] != false,
      quickCategoriesTitle:
          map['quickCategoriesTitle']?.toString() ?? 'Quick Categories',

      // Central Feature Flags
      proPageEnabled: map['proPageEnabled'] == true,
      supportPageEnabled: map['supportPageEnabled'] != false,
      notificationPreferencesEnabled:
          map['notificationPreferencesEnabled'] != false,
      socialSectionEnabled: map['socialSectionEnabled'] != false,

      // Dynamic Badges & Section Headings
      newBadgeDurationDays:
          int.tryParse(map['newBadgeDurationDays']?.toString() ?? '3') ?? 3,
      andamanJobsTitle:
          map['andamanJobsTitle']?.toString() ?? 'Andaman & Nicobar Vacancies',
      andamanJobsSubtitle: map['andamanJobsSubtitle']?.toString() ??
          'Island recruitment notifications',
      importantUpdatesTitle: map['importantUpdatesTitle']?.toString() ??
          'Important Updates & Results',
      importantUpdatesSubtitle: map['importantUpdatesSubtitle']?.toString() ??
          'Admit cards, results & answers',
      articlesTitle:
          map['articlesTitle']?.toString() ?? 'Preparation & Career Guides',
      articlesSubtitle: map['articlesSubtitle']?.toString() ??
          'Syllabus, guides and exam prep',

      // Merged Support & Ad-Free Settings
      supportPageHeading:
          map['supportPageHeading']?.toString() ?? 'Support Notify Jobs',
      supportPageSubtitle: map['supportPageSubtitle']?.toString() ??
          'Keep recruitment alerts free, fast & independent for everyone.',
      adFreeProductId:
          map['adFreeProductId']?.toString() ?? 'notify_jobs_pro_lifetime',
      adFreeProductLabel: map['adFreeProductLabel']?.toString() ??
          'Ad-Free Experience (Lifetime)',
      adFreeProductDescription: map['adFreeProductDescription']?.toString() ??
          'Browse all notifications, admit cards & results completely ad-free forever.',
      thankYouMessage: map['thankYouMessage']?.toString() ??
          'Thank you for your generous support! Your ad-free experience is active.',

      // Predefined Ad Slots
      adSlots: map['adSlots'] is Map
          ? Map<String, dynamic>.from(map['adSlots'])
          : const {},
    );
  }

  String get announcementActionUrl => announcementUrl;
  String get announcementActionText => announcementUrl.isNotEmpty ? 'View' : '';

  String get liveUpdatesSubtitle => 'Urgent notifications & breaking alerts';
  int get liveUpdatesMaxCount => liveUpdatesMaxItems;

  String get closingSoonSubtitle => 'Apply before deadline passes';
  int get closingSoonMaxCount => closingSoonMaxItems;

  String get popularSubtitle => 'Top viewed vacancies by aspirants';
  int get popularMaxCount => popularMaxItems;

  String get latestJobsSubtitle => 'Recently announced notifications';
  int get latestJobsMaxCount => latestJobsMaxItems;

  String get quickCategoriesSubtitle => 'Explore by department & qualification';
}
