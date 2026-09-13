import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import 'app_settings_provider.dart';

/// Real-time Firestore Content Stream Provider
final firestoreContentStreamProvider =
    StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .snapshots()
        .map((snapshot) {
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        try {
          final model = ContentModel.fromMap(data, doc.id);
          if (model.isPublished) {
            items.add(model);
          }
        } catch (_) {}
      }
      return items;
    });
  } catch (_) {
    return Stream.value(const <ContentModel>[]);
  }
});

/// Master Content Provider (reads Firestore if available, otherwise empty)
final allContentProvider = Provider<List<ContentModel>>((ref) {
  final streamVal = ref.watch(firestoreContentStreamProvider);
  return streamVal.maybeWhen(
    data: (items) => items,
    orElse: () => const <ContentModel>[],
  );
});

/// Latest Jobs Provider (Controlled by Admin settings)
final latestJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.latestJobsEnabled) return const <ContentModel>[];

  final jobs = all
      .where((item) =>
          item.contentType == 'government_job' ||
          item.contentType == 'private_job' ||
          item.contentType == 'andaman_job')
      .toList();
  return jobs.take(settings.latestJobsMaxItems).toList();
});

/// Popular This Week Provider (Controlled by Admin settings, real view metric)
final popularThisWeekProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.popularEnabled) return const <ContentModel>[];

  final copy = [...all];
  copy.sort((a, b) => b.views.compareTo(a.views));
  return copy.take(settings.popularMaxItems).toList();
});

/// Live Updates Provider (Controlled by Admin settings & showInLiveUpdates toggle)
final liveUpdatesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.liveUpdatesEnabled) return const <ContentModel>[];

  final marked = all.where((item) => item.showInLiveUpdates).toList();
  if (marked.isNotEmpty) {
    return marked.take(settings.liveUpdatesMaxItems).toList();
  }
  // Deterministic safe fallback: most recent published items
  final copy = [...all];
  copy.sort((a, b) => (b.publishedAt ?? '').compareTo(a.publishedAt ?? ''));
  return copy.take(settings.liveUpdatesMaxItems).toList();
});

/// Closing Soon Provider (Dynamically computed from real deadlines)
final closingSoonProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.closingSoonEnabled) return const <ContentModel>[];

  final now = DateTime.now();
  final thresholdDays = settings.closingSoonDaysThreshold;
  final maxDate = now.add(Duration(days: thresholdDays));

  final closingItems = all.where((item) {
    if (item.applicationLastDate == null || item.applicationLastDate!.isEmpty) {
      return false;
    }
    final lastDate = DateTime.tryParse(item.applicationLastDate!);
    if (lastDate == null) return false;
    return (lastDate.isAfter(now) || lastDate.day == now.day) &&
        lastDate.isBefore(maxDate);
  }).toList();

  closingItems.sort((a, b) {
    final da = DateTime.tryParse(a.applicationLastDate!) ?? now;
    final db = DateTime.tryParse(b.applicationLastDate!) ?? now;
    return da.compareTo(db);
  });

  return closingItems.take(settings.closingSoonMaxItems).toList();
});

/// Andaman & Nicobar Jobs Provider (Unified A&N model)
final andamanJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) =>
          item.isAndamanJob ||
          item.location.toLowerCase().contains('andaman') ||
          item.location.toLowerCase().contains('port blair'))
      .toList();
});

/// SSC Jobs Provider
final sscJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('ssc')).toList();
});

/// Railway Jobs Provider
final railwayJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('railway')).toList();
});

/// Banking Jobs Provider
final bankingJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.categoryIds.contains('banking')).toList();
});

/// Police & Defence Jobs Provider
final policeJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) => item.categoryIds.contains('police-defence'))
      .toList();
});

/// Admit Cards Provider (Specification 55)
final admitCardsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'admit_card').toList();
});

/// Results Provider (Specification 54)
final resultsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'result').toList();
});

/// Answer Keys Provider (Specification 56)
final answerKeysProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'answer_key').toList();
});

/// Syllabus Provider (Specification 57)
final syllabusProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'syllabus').toList();
});

/// Articles Provider (Specification 58)
final articlesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'article').toList();
});

/// Content by ID or Slug Provider
final contentByIdProvider =
    Provider.family<ContentModel?, String>((ref, idOrSlug) {
  final all = ref.watch(allContentProvider);
  try {
    return all
        .firstWhere((item) => item.id == idOrSlug || item.slug == idOrSlug);
  } catch (_) {
    return null;
  }
});

/// Alias for detail screen lookup
final contentDetailProvider = contentByIdProvider;

/// Search content across title, organization, role and location
final searchContentProvider =
    Provider.family<List<ContentModel>, String>((ref, query) {
  final all = ref.watch(allContentProvider);
  if (query.trim().isEmpty) return all;
  final q = query.toLowerCase();
  return all.where((item) {
    return item.title.toLowerCase().contains(q) ||
        item.organization.toLowerCase().contains(q) ||
        (item.department?.toLowerCase().contains(q) ?? false) ||
        item.jobRole.toLowerCase().contains(q) ||
        item.location.toLowerCase().contains(q);
  }).toList();
});

/// Parameter class for category filtering with limit
class CategoryContentParams {
  final String category;
  final int limit;

  const CategoryContentParams({required this.category, this.limit = 10});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryContentParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          limit == other.limit;

  @override
  int get hashCode => category.hashCode ^ limit.hashCode;
}

/// Category Content Provider with limit
final categoryContentProvider =
    Provider.family<List<ContentModel>, CategoryContentParams>((ref, params) {
  final all = ref.watch(allContentProvider);
  final filtered = all
      .where((item) =>
          item.contentType == params.category ||
          item.categoryIds.contains(params.category))
      .take(params.limit)
      .toList();
  return filtered;
});
