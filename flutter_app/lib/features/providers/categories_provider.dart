import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

/// Fallback canonical categories in case Firestore is unreachable (e.g. offline first launch)
const List<CategoryModel> defaultFallbackCategories = [
  CategoryModel(
    id: 'latest-jobs',
    name: 'Latest Jobs',
    shortName: 'Latest',
    slug: 'latest-jobs',
    icon: 'work',
    colorHex: '#159B76',
    order: 1,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=latest-jobs',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'andaman-nicobar',
    name: 'Andaman & Nicobar Jobs',
    shortName: 'A&N Jobs',
    slug: 'andaman-nicobar',
    icon: 'location_on',
    colorHex: '#0D9488',
    order: 2,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=andaman-nicobar',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'ssc',
    name: 'SSC Jobs',
    shortName: 'SSC',
    slug: 'ssc',
    icon: 'account_balance',
    colorHex: '#2563EB',
    order: 3,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=ssc',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'railway',
    name: 'Railway Jobs',
    shortName: 'Railway',
    slug: 'railway',
    icon: 'train',
    colorHex: '#DC2626',
    order: 4,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=railway',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'banking',
    name: 'Banking Jobs',
    shortName: 'Banking',
    slug: 'banking',
    icon: 'payments',
    colorHex: '#059669',
    order: 5,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=banking',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'police-defence',
    name: 'Police / Defence',
    shortName: 'Defence',
    slug: 'police-defence',
    icon: 'security',
    colorHex: '#D97706',
    order: 6,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=police-defence',
    contentScope: 'job',
  ),
  CategoryModel(
    id: 'admit-cards',
    name: 'Admit Cards',
    shortName: 'Admit Card',
    slug: 'admit-cards',
    icon: 'badge',
    colorHex: '#7C3AED',
    order: 7,
    isActive: true,
    showOnHome: true,
    destination: '/updates?tab=admit_cards',
    contentScope: 'update',
  ),
  CategoryModel(
    id: 'results',
    name: 'Results',
    shortName: 'Result',
    slug: 'results',
    icon: 'emoji_events',
    colorHex: '#EA580C',
    order: 8,
    isActive: true,
    showOnHome: true,
    destination: '/updates?tab=results',
    contentScope: 'update',
  ),
  CategoryModel(
    id: 'answer-keys',
    name: 'Answer Keys',
    shortName: 'Ans Key',
    slug: 'answer-keys',
    icon: 'fact_check',
    colorHex: '#0284C7',
    order: 9,
    isActive: true,
    showOnHome: true,
    destination: '/updates?tab=answer_keys',
    contentScope: 'update',
  ),
  CategoryModel(
    id: 'syllabus',
    name: 'Syllabus',
    shortName: 'Syllabus',
    slug: 'syllabus',
    icon: 'menu_book',
    colorHex: '#475569',
    order: 10,
    isActive: true,
    showOnHome: true,
    destination: '/updates?tab=syllabus',
    contentScope: 'update',
  ),
  CategoryModel(
    id: 'articles',
    name: 'Latest Articles',
    shortName: 'Articles',
    slug: 'articles',
    icon: 'article',
    colorHex: '#64748B',
    order: 11,
    isActive: true,
    showOnHome: true,
    destination: '/more',
    contentScope: 'article',
  ),
  CategoryModel(
    id: 'irbn-police',
    name: 'IRBN Police',
    shortName: 'IRBN Police',
    slug: 'irbn-police',
    icon: 'security',
    colorHex: '#1E3A8A',
    order: 12,
    isActive: true,
    showOnHome: true,
    destination: '/jobs?category=irbn-police',
    contentScope: 'job',
  ),
];

/// Real-time stream of categories from Firestore collection 'categories'.
/// Unauthenticated reads are allowed by security rules when isActive == true.
final firestoreCategoriesStreamProvider =
    StreamProvider<List<CategoryModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = <CategoryModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        try {
          final model = CategoryModel.fromMap(data, doc.id);
          if (model.isActive) {
            list.add(model);
          }
        } catch (_) {}
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  } catch (_) {
    return Stream.value(defaultFallbackCategories);
  }
});

/// Master Categories Provider:
/// Watches the real-time Firestore stream; if data arrives, uses live data.
/// If loading or offline error, falls back to safe default list.
final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  final streamVal = ref.watch(firestoreCategoriesStreamProvider);
  return streamVal.maybeWhen(
    data: (items) => items.isNotEmpty ? items : defaultFallbackCategories,
    orElse: () => defaultFallbackCategories,
  );
});

/// Filtered categories shown in User App (Master switch: isActive && showInUserApp)
final userAppCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoriesProvider);
  return all.where((c) => c.isActive && c.showInUserApp).toList();
});

/// Quick categories for Home Screen (showOnHome && showInQuickCategories)
final homeQuickCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(userAppCategoriesProvider);
  return all.where((c) => c.showOnHome && c.showInQuickCategories).toList();
});

/// Categories for Jobs Screen filter bar (showInJobsFilters)
final jobsFilterCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(userAppCategoriesProvider);
  return all.where((c) => c.showInJobsFilters).toList();
});

/// Categories for Updates Screen (showInUpdates)
final updatesCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(userAppCategoriesProvider);
  return all.where((c) => c.showInUpdates).toList();
});

/// Categories for Search Screen filter pills (showInSearch)
final searchCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(userAppCategoriesProvider);
  return all.where((c) => c.showInSearch).toList();
});
