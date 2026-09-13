import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_model.dart';

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

/// Latest Government Jobs Provider
final latestJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all.where((item) => item.contentType == 'government_job').toList();
});

/// Popular This Week (Specification 86)
final popularThisWeekProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  final copy = [...all];
  copy.sort((a, b) => b.views.compareTo(a.views));
  return copy.take(5).toList();
});

/// Andaman & Nicobar Jobs Provider (Specification 52)
final andamanJobsProvider = Provider<List<ContentModel>>((ref) {
  final all = ref.watch(allContentProvider);
  return all
      .where((item) =>
          item.categoryIds.contains('andaman-nicobar') ||
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
