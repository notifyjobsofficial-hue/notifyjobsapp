import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/providers/storage_provider.dart';

/// Real Total View Counts Service with Anti-Inflation Throttling
///
/// Rules (Specification Part A, Items 1 - 4):
/// 1. Increments ONLY on meaningful detail page opens (JobDetailScreen, UpdateDetailScreen, ArticleDetailScreen).
///    Never on card render, list scroll, Riverpod rebuilds, previews, or admin edits.
/// 2. Anti-inflation Throttling: 1 view per contentId per device within 30 minutes.
/// 3. Atomic Firestore Increment: Uses FieldValue.increment(1) without read-then-write race conditions.
/// 4. Resilient Fallback: If direct client Firestore update encounters permissions or offline,
///    gracefully fails or dispatches through the Cloudflare Worker increment endpoint.
class ViewCountService {
  static const Duration throttleDuration = Duration(minutes: 30);
  static const String _throttlePrefix = 'nj_view_throttle_';

  final SharedPreferences? _prefs;
  final FirebaseFirestore? _firestore;
  final String workerUrl;

  ViewCountService({
    SharedPreferences? prefs,
    FirebaseFirestore? firestore,
    this.workerUrl = 'https://notify-jobs-fcm-worker.workers.dev',
  })  : _prefs = prefs,
        _firestore = firestore;

  /// Meaningfully record a view for content with 30-minute anti-inflation throttling.
  /// Returns `true` if an increment was executed, or `false` if throttled or blocked.
  Future<bool> recordView(String contentId, {String? contentType}) async {
    if (contentId.trim().isEmpty) return false;

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final key = '$_throttlePrefix$contentId';
      final lastViewedMs = prefs.getInt(key);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (lastViewedMs != null) {
        final elapsedMs = nowMs - lastViewedMs;
        if (elapsedMs < throttleDuration.inMilliseconds) {
          // Throttled: User viewed this content less than 30 minutes ago on this device
          return false;
        }
      }

      // Record new throttle timestamp locally
      await prefs.setInt(key, nowMs);

      // 1. Primary Path: Direct Firestore Atomic Increment
      try {
        final fs = _firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
        if (fs != null) {
          await fs.collection('content').doc(contentId).update({
            'viewCount': FieldValue.increment(1),
            'views': FieldValue.increment(1),
          });
          return true;
        }
      } catch (fsError) {
        debugPrint('Direct Firestore viewCount increment note: $fsError');
      }

      // 2. Secondary Resilient Path: Cloudflare Worker backend increment
      if (workerUrl.isNotEmpty) {
        try {
          final uri = Uri.parse('$workerUrl/api/views/increment');
          final response = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'contentId': contentId}),
              )
              .timeout(const Duration(seconds: 4));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return true;
          }
        } catch (workerError) {
          debugPrint('Worker viewCount increment note: $workerError');
        }
      }
    } catch (e) {
      debugPrint('ViewCountService exception for $contentId: $e');
    }

    return false;
  }

  /// Check whether content is currently within the 30-minute throttle window
  bool isThrottled(String contentId) {
    final prefs = _prefs;
    if (prefs == null) return false;
    final lastViewedMs = prefs.getInt('$_throttlePrefix$contentId');
    if (lastViewedMs == null) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastViewedMs;
    return elapsed < throttleDuration.inMilliseconds;
  }
}

/// Riverpod provider for ViewCountService
final viewCountServiceProvider = Provider<ViewCountService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ViewCountService(prefs: storage.sharedPreferences);
});
