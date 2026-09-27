import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import 'storage_provider.dart';
import '../models/content_model.dart';
import 'content_providers.dart';

/// Notification item model for the unified notification inbox & state
class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final String destination;
  final bool isRead;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.destination,
    this.isRead = false,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    String? destination,
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      destination: destination ?? this.destination,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notification state holding inbox items and unread status
class NotificationState {
  final List<AppNotificationItem> items;
  final int unreadCount;
  final DateTime? lastSeenNotificationAt;
  final bool isInitialized;

  const NotificationState({
    this.items = const [],
    this.unreadCount = 0,
    this.lastSeenNotificationAt,
    this.isInitialized = false,
  });

  bool get hasUnread => unreadCount > 0;

  NotificationState copyWith({
    List<AppNotificationItem>? items,
    int? unreadCount,
    DateTime? lastSeenNotificationAt,
    bool? isInitialized,
  }) {
    return NotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      lastSeenNotificationAt:
          lastSeenNotificationAt ?? this.lastSeenNotificationAt,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Safe timestamp parser that defaults to a historical baseline (2020-01-01),
/// preventing malformed/missing timestamps from triggering fake unread badges.
DateTime parseSafeNotificationTimestamp(String? isoString) {
  if (isoString == null || isoString.trim().isEmpty) {
    return DateTime(2020, 1, 1);
  }
  try {
    final parsed = DateTime.tryParse(isoString.trim());
    return parsed ?? DateTime(2020, 1, 1);
  } catch (_) {
    return DateTime(2020, 1, 1);
  }
}

/// Notifier managing notification unread logic and persistence
class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;
  final StorageService _storage;

  NotificationNotifier(this._ref, this._storage)
      : super(const NotificationState()) {
    _init();
  }

  void _init() {
    // Listen to changes in allContentProvider (Firestore stream or local cache)
    _ref.listen<List<ContentModel>>(
      allContentProvider,
      (previous, next) {
        _processContent(next);
      },
      fireImmediately: true,
    );
  }

  void _processContent(List<ContentModel> contentList) {
    final clearedIds = _storage.getClearedNotificationIds().toSet();
    final readIds = _storage.getReadNotificationIds().toSet();
    final isInit = _storage.isNotificationInitialized();
    final lastSeenIso = _storage.getLastSeenNotificationAt();
    final DateTime? lastSeen =
        lastSeenIso != null ? DateTime.tryParse(lastSeenIso) : null;

    final items = <AppNotificationItem>[];

    for (final c in contentList) {
      if (clearedIds.contains(c.id)) continue;

      // Extract timestamp safely: fallback to 2020-01-01, NEVER DateTime.now()
      DateTime dt = DateTime(2020, 1, 1);
      if (c.publishedAt != null && c.publishedAt!.isNotEmpty) {
        dt = parseSafeNotificationTimestamp(c.publishedAt);
      } else if (c.updatedAt != null && c.updatedAt!.isNotEmpty) {
        dt = parseSafeNotificationTimestamp(c.updatedAt);
      }

      String typeLabel = 'JOB';
      String route = '/job/${c.id}';
      if (c.contentType == 'admit_card') {
        typeLabel = 'ADMIT CARD';
        route = '/update/${c.id}';
      } else if (c.contentType == 'result') {
        typeLabel = 'RESULT';
        route = '/update/${c.id}';
      } else if (c.contentType == 'answer_key') {
        typeLabel = 'ANSWER KEY';
        route = '/update/${c.id}';
      } else if (c.contentType == 'syllabus') {
        typeLabel = 'SYLLABUS';
        route = '/update/${c.id}';
      } else if (c.contentType == 'article') {
        typeLabel = 'ARTICLE';
        route = '/article/${c.id}';
      }

      items.add(AppNotificationItem(
        id: c.id,
        title: c.title,
        message: c.organization.isNotEmpty
            ? '${c.organization} • ${c.jobRole.isNotEmpty ? c.jobRole : typeLabel}'
            : (c.excerpt.isNotEmpty ? c.excerpt : 'Tap to view full details.'),
        type: typeLabel,
        timestamp: dt,
        destination: route,
        isRead: readIds.contains(c.id),
      ));
    }

    // Sort descending by timestamp
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // CASE 1: FRESH INSTALL / CLEAR APP DATA
    // Historical notifications must NEVER trigger an unread red dot.
    if (!isInit) {
      DateTime baseline;
      if (items.isNotEmpty) {
        // As per Constraint 2: Anchor baseline to newest valid Firestore/server notification timestamp
        // Never rely on device DateTime.now() which can cause clock-skew bugs
        baseline = items.first.timestamp;
      } else {
        baseline = DateTime.now();
      }

      // Persist baseline once content is loaded or if initialized
      if (contentList.isNotEmpty) {
        _storage.setLastSeenNotificationAt(baseline.toIso8601String());
        _storage.setNotificationInitialized(true);
      }

      final readItems = items.map((i) => i.copyWith(isRead: true)).toList();

      state = NotificationState(
        items: readItems,
        unreadCount: 0,
        lastSeenNotificationAt: baseline,
        isInitialized: contentList.isNotEmpty,
      );
      return;
    }

    // CASE 2: NORMAL RUN (ALREADY INITIALIZED)
    // Only notifications with timestamp > lastSeen AND not in readIds are unread.
    int unread = 0;
    final updatedItems = <AppNotificationItem>[];

    for (final item in items) {
      final bool isUnread = !readIds.contains(item.id) &&
          (lastSeen != null && item.timestamp.isAfter(lastSeen));

      if (isUnread) {
        unread++;
        updatedItems.add(item.copyWith(isRead: false));
      } else {
        updatedItems.add(item.copyWith(isRead: true));
      }
    }

    state = NotificationState(
      items: updatedItems,
      unreadCount: unread,
      lastSeenNotificationAt: lastSeen,
      isInitialized: true,
    );
  }

  /// Mark all current notifications as seen/read (called when opening Notification Inbox)
  Future<void> markAllAsSeen() async {
    DateTime newest;
    if (state.items.isNotEmpty) {
      newest = state.items.first.timestamp;
    } else {
      newest = DateTime.now();
    }

    await _storage.setLastSeenNotificationAt(newest.toIso8601String());
    await _storage.markNotificationsRead(state.items.map((i) => i.id));

    final updatedItems =
        state.items.map((i) => i.copyWith(isRead: true)).toList();

    state = state.copyWith(
      items: updatedItems,
      unreadCount: 0,
      lastSeenNotificationAt: newest,
    );
  }

  /// Mark a single notification item as read
  Future<void> markItemRead(String id) async {
    await _storage.markNotificationRead(id);

    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    final unread = updatedItems.where((i) => !i.isRead).length;

    state = state.copyWith(
      items: updatedItems,
      unreadCount: unread,
    );
  }

  /// Clear all notifications from inbox
  Future<void> clearAll() async {
    final allIds = state.items.map((i) => i.id).toList();
    await _storage.clearAllNotifications(allIds);

    state = state.copyWith(
      items: const [],
      unreadCount: 0,
    );
  }
}

/// Notification State Provider
final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationNotifier(ref, storage);
});

/// Unread notification count provider
final notificationUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationStateProvider).unreadCount;
});

/// Boolean provider indicating whether there are unread notifications
final notificationHasUnreadProvider = Provider<bool>((ref) {
  return ref.watch(notificationStateProvider).hasUnread;
});
