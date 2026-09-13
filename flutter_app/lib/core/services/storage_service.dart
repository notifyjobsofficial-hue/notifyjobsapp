import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local Persistence Service for Offline Storage (Specification 6, 25, 47, 85, 100)
class StorageService {
  static const String _keySavedJobs = 'nj_saved_jobs_v1';
  static const String _keyRecentSearches = 'nj_recent_searches_v1';
  static const String _keyUnlockedNotifications = 'nj_unlocked_docs_v1';
  static const String _keyThemeMode = 'nj_theme_mode_v1';
  static const String _keySubscribedTopics = 'nj_subscribed_topics_v1';
  static const String _keyRecentViews = 'nj_recent_views_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- GENERIC KEY-VALUE HELPERS ---
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  // --- SAVED JOBS (Works 100% Offline) ---
  List<Map<String, dynamic>> getSavedJobs() {
    final rawList = _prefs.getStringList(_keySavedJobs) ?? [];
    return rawList
        .map((item) {
          try {
            return jsonDecode(item) as Map<String, dynamic>;
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  bool isJobSaved(String contentId) {
    final jobs = getSavedJobs();
    return jobs.any((j) => j['id'] == contentId);
  }

  Future<bool> saveJob(Map<String, dynamic> job) async {
    final jobs = getSavedJobs();
    jobs.removeWhere((j) => j['id'] == job['id']);
    jobs.insert(0, job);
    final rawList = jobs.map((j) => jsonEncode(j)).toList();
    return _prefs.setStringList(_keySavedJobs, rawList);
  }

  Future<bool> removeSavedJob(String contentId) async {
    final jobs = getSavedJobs();
    jobs.removeWhere((j) => j['id'] == contentId);
    final rawList = jobs.map((j) => jsonEncode(j)).toList();
    return _prefs.setStringList(_keySavedJobs, rawList);
  }

  // --- RECENT SEARCHES ---
  List<String> getRecentSearches() {
    return _prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> addRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final list = getRecentSearches();
    list.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    list.insert(0, trimmed);
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    await _prefs.setStringList(_keyRecentSearches, list);
  }

  Future<void> removeRecentSearch(String term) async {
    final list = getRecentSearches();
    list.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    await _prefs.setStringList(_keyRecentSearches, list);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_keyRecentSearches);
  }

  // --- REWARDED AD UNLOCK CACHE (Specification 47) ---
  bool isNotificationUnlocked(String contentId, {int durationMinutes = 30}) {
    final rawMap = _prefs.getString(_keyUnlockedNotifications);
    if (rawMap == null) return false;
    try {
      final Map<String, dynamic> map = jsonDecode(rawMap);
      final unlockedAtMs = map[contentId] as int?;
      if (unlockedAtMs == null) return false;

      final expiryMs = unlockedAtMs + (durationMinutes * 60 * 1000);
      return DateTime.now().millisecondsSinceEpoch < expiryMs;
    } catch (_) {
      return false;
    }
  }

  Future<void> setNotificationUnlocked(String contentId) async {
    Map<String, dynamic> map = {};
    final rawMap = _prefs.getString(_keyUnlockedNotifications);
    if (rawMap != null) {
      try {
        map = jsonDecode(rawMap) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[contentId] = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setString(_keyUnlockedNotifications, jsonEncode(map));
  }

  // --- THEME MODE PREFERENCE ---
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // --- SUBSCRIBED TOPICS ---
  List<String> getSubscribedTopics() {
    return _prefs.getStringList(_keySubscribedTopics) ??
        ['all_updates', 'jobs'];
  }

  Future<void> setSubscribedTopics(List<String> topics) async {
    await _prefs.setStringList(_keySubscribedTopics, topics);
  }

  // --- VIEW DEDUPLICATION (Specification 85: Max once per 6 hours) ---
  bool canRecordView(String contentId) {
    final rawMap = _prefs.getString(_keyRecentViews);
    if (rawMap == null) return true;
    try {
      final Map<String, dynamic> map = jsonDecode(rawMap);
      final lastViewMs = map[contentId] as int?;
      if (lastViewMs == null) return true;

      const sixHoursMs = 6 * 60 * 60 * 1000;
      return DateTime.now().millisecondsSinceEpoch - lastViewMs > sixHoursMs;
    } catch (_) {
      return true;
    }
  }

  Future<void> markViewed(String contentId) async {
    Map<String, dynamic> map = {};
    final rawMap = _prefs.getString(_keyRecentViews);
    if (rawMap != null) {
      try {
        map = jsonDecode(rawMap) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[contentId] = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setString(_keyRecentViews, jsonEncode(map));
  }
}
