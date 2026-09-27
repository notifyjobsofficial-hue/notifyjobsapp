import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';
import 'app_settings_provider.dart';
import '../../core/utils/performance_tracker.dart';
import '../../core/utils/status_engine.dart';

// =============================================================================
// INDEPENDENT HOME SECTION STREAM PROVIDERS (Progressive Section Loading)
// =============================================================================

/// 1. Home Live Updates Stream Provider (Limit: 15, showInLiveUpdates == true)
final homeLiveUpdatesStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final settings = ref.watch(appSettingsProvider);
  if (!settings.liveUpdatesEnabled) {
    return Stream.value(const <ContentModel>[]);
  }

  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .where('showInLiveUpdates', isEqualTo: true)
        .limit(25)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('LiveUpdatesLoad');
      final list = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final model = ContentModel.fromMap(data, doc.id);
          if (model.isPublished && model.showInUserApp) {
            list.add(model);
          }
        } catch (e) {
          debugPrint('[FIRESTORE] LiveUpdates parsing error in ${doc.id}: $e');
        }
      }
      list.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint('[FIRESTORE QUERY: LiveUpdates] returned ${list.length} docs');
      return list.take(settings.liveUpdatesMaxItems.clamp(1, 15)).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: LiveUpdates] $error');
      // Resilient fallback: take top items from allContentProvider
      final all = ref.read(allContentProvider);
      final fallback = all
          .where((item) =>
              (item.showInLiveUpdates || item.isJob) && item.showInUserApp)
          .take(settings.liveUpdatesMaxItems.clamp(1, 15))
          .toList();
      return fallback;
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: LiveUpdates] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 2. Home Latest Jobs Stream Provider (Limit: 15, published jobs)
final homeLatestJobsStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final settings = ref.watch(appSettingsProvider);
  if (!settings.latestJobsEnabled) {
    return Stream.value(const <ContentModel>[]);
  }

  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .limit(50)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('LatestJobsLoad');
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final model = ContentModel.fromMap(data, doc.id);
          if (model.isPublished &&
              model.showInUserApp &&
              model.isJob &&
              model.showInLatestJobs) {
            items.add(model);
          }
        } catch (e) {
          debugPrint('[FIRESTORE] LatestJobs parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint('[FIRESTORE QUERY: LatestJobs] returned ${items.length} jobs');
      return items.take(settings.latestJobsMaxItems.clamp(1, 15)).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: LatestJobs] $error');
      return <ContentModel>[];
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: LatestJobs] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 3. Home Closing Soon Stream Provider (Limit: 8, deadline in future)
final homeClosingSoonStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.closingSoonEnabled) {
    return Stream.value(const <ContentModel>[]);
  }

  final nowStr = DateTime.now().toIso8601String().split('T').first;
  final closing = all.where((item) {
    if (!item.isJob || !item.showInClosingSoon) return false;
    final lastDate = item.applicationLastDate;
    if (lastDate == null || lastDate.trim().isEmpty) return false;
    return lastDate.compareTo(nowStr) >= 0;
  }).toList();

  closing.sort((a, b) =>
      (a.applicationLastDate ?? '').compareTo(b.applicationLastDate ?? ''));
  debugPrint(
      '[FIRESTORE QUERY: ClosingSoon] derived ${closing.length} closing-soon jobs');
  return Stream.value(
      closing.take(settings.closingSoonMaxItems.clamp(1, 8)).toList());
});

/// 4. Home Popular Jobs Stream Provider (Limit: 8, views descending)
final homePopularJobsStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final settings = ref.watch(appSettingsProvider);
  if (!settings.popularEnabled) {
    return Stream.value(const <ContentModel>[]);
  }

  final jobs = all.where((item) => item.isJob).toList();
  jobs.sort((a, b) => b.views.compareTo(a.views));
  debugPrint(
      '[FIRESTORE QUERY: PopularJobs] derived ${jobs.length} popular jobs');
  return Stream.value(jobs.take(settings.popularMaxItems.clamp(1, 8)).toList());
});

/// 5. Home Andaman & Nicobar Jobs Stream Provider (Limit: 4)
final homeAndamanJobsStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('ANJobsLoad');
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final model = ContentModel.fromMap(data, doc.id);
          if (model.isPublished &&
              model.showInUserApp &&
              (model.contentType == 'andaman_job' ||
                  model.showInAndamanSection ||
                  model.isAndamanJob)) {
            items.add(model);
          }
        } catch (e) {
          debugPrint('[FIRESTORE] AndamanJobs parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint(
          '[FIRESTORE QUERY: AndamanJobs] returned ${items.length} items');
      return items.take(4).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: AndamanJobs] $error');
      // Resilient fallback: filter from allContentProvider
      final all = ref.read(allContentProvider);
      return all.where((i) => i.isAndamanJob).take(4).toList();
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: AndamanJobs] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 6. Home Admit Cards Stream Provider (Limit: 4)
final homeAdmitCardsStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .where('contentType', isEqualTo: 'admit_card')
        .limit(6)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('UpdatesLoad');
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          items.add(ContentModel.fromMap(data, doc.id));
        } catch (e) {
          debugPrint('[FIRESTORE] AdmitCards parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint(
          '[FIRESTORE QUERY: AdmitCards] returned ${items.length} cards');
      return items.take(4).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: AdmitCards] $error');
      return <ContentModel>[];
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: AdmitCards] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 7. Home Results Stream Provider (Limit: 4)
final homeResultsStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .where('contentType', isEqualTo: 'result')
        .limit(6)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('UpdatesLoad');
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          items.add(ContentModel.fromMap(data, doc.id));
        } catch (e) {
          debugPrint('[FIRESTORE] Results parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint('[FIRESTORE QUERY: Results] returned ${items.length} results');
      return items.take(4).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: Results] $error');
      return <ContentModel>[];
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: Results] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 8. Home Articles Stream Provider (Limit: 4)
final homeArticlesStreamProvider = StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .where('contentType', isEqualTo: 'article')
        .limit(6)
        .snapshots()
        .map((snapshot) {
      PerformanceTracker.mark('ArticlesLoad');
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          items.add(ContentModel.fromMap(data, doc.id));
        } catch (e) {
          debugPrint('[FIRESTORE] Articles parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint(
          '[FIRESTORE QUERY: Articles] returned ${items.length} articles');
      return items.take(4).toList();
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: Articles] $error');
      return <ContentModel>[];
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: Articles] $e');
    return Stream.value(const <ContentModel>[]);
  }
});

/// 9. Real Published Data Provider for Today's Updates Summary Card (Phase 4)
final todaysUpdatesSummaryProvider =
    Provider<({int newJobs, int admitCards, int results, int closingSoon})>(
        (ref) {
  final all = ref.watch(allContentProvider);
  final jobs = all.where((item) => item.isJob).toList();
  final admitCardsList =
      all.where((item) => item.contentType == 'admit_card').toList();
  final resultsList =
      all.where((item) => item.contentType == 'result').toList();

  final now = DateTime.now();

  // Real recent cutoff: published within last 7 days
  bool isRecent(String? dateStr, {int days = 7}) {
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    final dt = DateTime.tryParse(dateStr.trim());
    if (dt == null) return false;
    final diff = now.difference(dt);
    return !diff.isNegative && diff.inDays <= days;
  }

  // 1. Real count of new jobs published in last 7 days
  final int jobCount =
      jobs.where((j) => isRecent(j.publishedAt, days: 7)).length;

  // 2. Real count of admit cards released in last 7 days
  final int admitCount =
      admitCardsList.where((a) => isRecent(a.publishedAt, days: 7)).length;

  // 3. Real count of results published in last 7 days
  final int resultCount =
      resultsList.where((r) => isRecent(r.publishedAt, days: 7)).length;

  // 4. Real count of active jobs with deadline approaching within 5 days
  final int closingCount = jobs.where((j) {
    if (j.statusOverride == 'closed') return false;
    if (j.statusOverride == 'closing_soon' ||
        j.statusOverride == 'closing_today') {
      return true;
    }
    if (j.applicationLastDate == null ||
        j.applicationLastDate!.trim().isEmpty) {
      return false;
    }
    final dt = DateTime.tryParse(j.applicationLastDate!.trim());
    if (dt == null) return false;
    final diff = dt.difference(now);
    return !diff.isNegative && diff.inDays <= 5;
  }).length;

  debugPrint(
      '[SUMMARY CARD] Dynamic metrics: newJobs=$jobCount, admitCards=$admitCount, results=$resultCount, closingSoon=$closingCount');

  return (
    newJobs: jobCount,
    admitCards: admitCount,
    results: resultCount,
    closingSoon: closingCount,
  );
});

/// Provider for genuinely urgent content on Home (Only non-empty when items are actually urgent)
final urgentContentProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final now = DateTime.now();

  final urgentList = <ContentModel>[];

  for (final item in all) {
    // 0. Explicitly marked as urgent by Admin
    if (item.urgent) {
      urgentList.add(item);
      continue;
    }

    final status = StatusEngine.compute(
      contentType: item.contentType,
      lastDate: item.lastDateParsed,
      startDate: item.applicationStartDate != null
          ? DateTime.tryParse(item.applicationStartDate!)
          : null,
      explicitStatus: item.statusOverride,
    );

    // 1. Status evaluated as urgent (Closing Today, 1 Day Left, etc.)
    if (status.isUrgent) {
      urgentList.add(item);
      continue;
    }

    // 2. Application deadline within 48 hours
    if (item.applicationLastDate != null) {
      final lastDate = DateTime.tryParse(item.applicationLastDate!);
      if (lastDate != null) {
        final diff = lastDate.difference(now);
        if (!diff.isNegative && diff.inHours <= 48) {
          urgentList.add(item);
          continue;
        }
      }
    }

    // 3. Recently published Admit Card or Result (last 48h)
    if (item.contentType == 'admit_card' || item.contentType == 'result') {
      if (item.publishedAt != null) {
        final pubDate = DateTime.tryParse(item.publishedAt!);
        if (pubDate != null && now.difference(pubDate).inHours <= 48) {
          urgentList.add(item);
          continue;
        }
      }
    }
  }

  // Deduplicate by ID and take up to 4
  final seen = <String>{};
  return urgentList.where((item) => seen.add(item.id)).take(4).toList();
});

// =============================================================================
// LISTING & SHARED PROVIDERS (Used by JobsScreen, UpdatesScreen, Search)
// =============================================================================

/// Real-time Firestore Content Stream Provider with reasonable limit for listings
final firestoreContentStreamProvider =
    StreamProvider<List<ContentModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final items = <ContentModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final model = ContentModel.fromMap(data, doc.id);
          if (model.isPublished && model.showInUserApp) {
            items.add(model);
          }
        } catch (e) {
          debugPrint(
              '[FIRESTORE] ContentStream parsing error in ${doc.id}: $e');
        }
      }
      items.sort((a, b) => (b.publishedAt ?? b.updatedAt ?? '')
          .compareTo(a.publishedAt ?? a.updatedAt ?? ''));
      debugPrint(
          '[FIRESTORE QUERY: AllContentStream] successfully loaded ${items.length} published docs');
      return items;
    }).handleError((error, stackTrace) {
      debugPrint('[FIRESTORE ERROR: firestoreContentStreamProvider] $error');
      return <ContentModel>[];
    });
  } catch (e) {
    debugPrint('[FIRESTORE EXCEPTION: firestoreContentStreamProvider] $e');
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

/// Latest Jobs Provider
final latestJobsProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homeLatestJobsStreamProvider);
  return homeVal.maybeWhen(
    data: (jobs) => jobs.isNotEmpty
        ? jobs
        : ref
            .watch(allContentProvider)
            .where((item) => item.isJob)
            .take(10)
            .toList(),
    orElse: () {
      final all = ref.watch(allContentProvider);
      return all.where((item) => item.isJob).take(10).toList();
    },
  );
});

/// Popular This Week Provider
final popularThisWeekProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homePopularJobsStreamProvider);
  return homeVal.maybeWhen(
    data: (jobs) => jobs.isNotEmpty
        ? jobs
        : () {
            final all = ref.watch(allContentProvider);
            final copy = all.where((item) => item.isJob).toList();
            copy.sort((a, b) => b.views.compareTo(a.views));
            return copy.take(5).toList();
          }(),
    orElse: () {
      final all = ref.watch(allContentProvider);
      final copy = all.where((item) => item.isJob).toList();
      copy.sort((a, b) => b.views.compareTo(a.views));
      return copy.take(5).toList();
    },
  );
});

/// Live Updates Provider
final liveUpdatesProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homeLiveUpdatesStreamProvider);
  return homeVal.maybeWhen(
    data: (items) => items.isNotEmpty
        ? items
        : ref
            .watch(allContentProvider)
            .where((item) => item.showInLiveUpdates || item.isJob)
            .take(8)
            .toList(),
    orElse: () {
      final all = ref.watch(allContentProvider);
      return all
          .where((item) => item.showInLiveUpdates || item.isJob)
          .take(8)
          .toList();
    },
  );
});

/// Closing Soon Provider
final closingSoonProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homeClosingSoonStreamProvider);
  return homeVal.maybeWhen(
    data: (items) => items,
    orElse: () => const <ContentModel>[],
  );
});

/// Andaman & Nicobar Jobs Provider
final andamanJobsProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homeAndamanJobsStreamProvider);
  return homeVal.maybeWhen(
    data: (items) => items.isNotEmpty
        ? items
        : ref
            .watch(allContentProvider)
            .where((item) => item.isAndamanJob)
            .toList(),
    orElse: () {
      final all = ref.watch(allContentProvider);
      return all.where((item) => item.isAndamanJob).toList();
    },
  );
});

/// Admit Cards Provider
final admitCardsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'admit_card').toList();
});

/// Results Provider
final resultsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'result').toList();
});

/// Answer Keys Provider
final answerKeysProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'answer_key').toList();
});

/// Syllabus Provider
final syllabusProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'syllabus').toList();
});

/// Exam Dates Provider
final examDatesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'exam_date').toList();
});

/// Govt Updates Provider
final govtUpdatesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) =>
          item.contentType == 'govt_update' ||
          item.contentType == 'admission' ||
          item.contentType == 'scholarship')
      .toList();
});

/// All Updates Combined Provider (all non-job, non-article updates)
final allUpdatesProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) =>
          item.contentType != 'government_job' &&
          item.contentType != 'private_job' &&
          item.contentType != 'andaman_job' &&
          item.contentType != 'article')
      .toList();
});

/// Articles Provider
final articlesProvider = Provider<List<ContentModel>>((ref) {
  final homeVal = ref.watch(homeArticlesStreamProvider);
  return homeVal.maybeWhen(
    data: (items) => items.isNotEmpty
        ? items
        : ref
            .watch(allContentProvider)
            .where((item) => item.contentType == 'article')
            .toList(),
    orElse: () {
      final all = ref.watch(allContentProvider);
      return all.where((item) => item.contentType == 'article').toList();
    },
  );
});

// =============================================================================
// DETAIL & SEARCH LOOKUP (Direct On-Demand Fetching Without Giant Collection)
// =============================================================================

/// Single Content On-Demand Fetcher (avoids downloading all documents)
final singleContentFutureProvider =
    FutureProvider.family<ContentModel?, String>((ref, idOrSlug) async {
  if (idOrSlug.trim().isEmpty) return null;

  try {
    final docSnap = await FirebaseFirestore.instance
        .collection('content')
        .doc(idOrSlug)
        .get();
    if (docSnap.exists && docSnap.data() != null) {
      final data = docSnap.data()!;
      data['id'] = docSnap.id;
      final model = ContentModel.fromMap(data, docSnap.id);
      debugPrint(
          '[FIRESTORE] singleContent loaded docId: ${model.id} (${model.title})');
      return model;
    }

    // Fallback: search by slug with public publication filter
    final querySnap = await FirebaseFirestore.instance
        .collection('content')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'published')
        .where('slug', isEqualTo: idOrSlug)
        .limit(1)
        .get();
    if (querySnap.docs.isNotEmpty) {
      final d = querySnap.docs.first;
      final data = d.data();
      data['id'] = d.id;
      final model = ContentModel.fromMap(data, d.id);
      debugPrint(
          '[FIRESTORE] singleContent loaded slug: ${model.slug} (${model.title})');
      return model;
    }
  } catch (e) {
    debugPrint('[FIRESTORE ERROR: singleContent] idOrSlug=$idOrSlug: $e');
  }
  return null;
});

/// Content by ID or Slug Provider
final contentByIdProvider =
    Provider.family<ContentModel?, String>((ref, idOrSlug) {
  // 1. Search in all active memory streams first
  final allLoaded = [
    ...ref.watch(homeLatestJobsStreamProvider).value ?? [],
    ...ref.watch(homeAndamanJobsStreamProvider).value ?? [],
    ...ref.watch(homePopularJobsStreamProvider).value ?? [],
    ...ref.watch(homeLiveUpdatesStreamProvider).value ?? [],
    ...ref.watch(homeAdmitCardsStreamProvider).value ?? [],
    ...ref.watch(homeResultsStreamProvider).value ?? [],
    ...ref.watch(homeArticlesStreamProvider).value ?? [],
    ...ref.watch(allContentProvider),
  ];

  for (final item in allLoaded) {
    if (item.id == idOrSlug || item.slug == idOrSlug) {
      return item;
    }
  }

  // 2. Fallback to asynchronous on-demand single document fetch
  final asyncDoc = ref.watch(singleContentFutureProvider(idOrSlug));
  return asyncDoc.value;
});

/// Alias for detail screen lookup
final contentDetailProvider = contentByIdProvider;

/// Search content across title, organization, role and location
final searchContentProvider =
    Provider.family<List<ContentModel>, String>((ref, query) {
  final all = ref.watch(allContentProvider);
  if (query.trim().isEmpty) {
    return all.where((item) => item.showInSearch).toList();
  }
  final q = query.toLowerCase();
  return all.where((item) {
    if (!item.showInSearch) return false;
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
          item.categoryIds.contains(params.category) ||
          item.isCategoryMatch(params.category))
      .take(params.limit)
      .toList();
  return filtered;
});
