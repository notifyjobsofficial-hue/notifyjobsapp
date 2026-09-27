import 'package:flutter/material.dart';

/// Category model for Notify Jobs (Specification 59, 129)
class CategoryModel {
  final String id;
  final String name;
  final String? shortName;
  final String slug;
  final String icon;
  final String colorHex;
  final int order;
  final bool isActive;
  final bool showOnHome;
  final bool showInUserApp;
  final bool showInQuickCategories;
  final bool showInJobsFilters;
  final bool showInUpdates;
  final bool showInSearch;
  final bool showInAdminSidebar;
  final String? destination;
  final String? contentScope;

  const CategoryModel({
    required this.id,
    required this.name,
    this.shortName,
    required this.slug,
    required this.icon,
    required this.colorHex,
    required this.order,
    this.isActive = true,
    this.showOnHome = true,
    this.showInUserApp = true,
    this.showInQuickCategories = true,
    this.showInJobsFilters = true,
    this.showInUpdates = true,
    this.showInSearch = true,
    this.showInAdminSidebar = true,
    this.destination,
    this.contentScope,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? 'Category',
      shortName: map['shortName']?.toString(),
      slug: map['slug']?.toString() ?? docId,
      icon: map['icon']?.toString() ?? 'work',
      colorHex:
          map['color']?.toString() ?? map['colorHex']?.toString() ?? '#159B76',
      order: int.tryParse(map['order']?.toString() ?? '99') ?? 99,
      isActive: map['isActive'] != false && map['enabled'] != false,
      showOnHome: map['showOnHome'] != false,
      showInUserApp: map['showInUserApp'] != false,
      showInQuickCategories: map['showInQuickCategories'] != false,
      showInJobsFilters: map['showInJobsFilters'] != false,
      showInUpdates: map['showInUpdates'] != false,
      showInSearch: map['showInSearch'] != false,
      showInAdminSidebar: map['showInAdminSidebar'] != false,
      destination: map['destination']?.toString(),
      contentScope: map['contentScope']?.toString(),
    );
  }

  /// Label used on chips and cards to prevent awkward text truncation
  String get displayName => (shortName != null && shortName!.trim().isNotEmpty)
      ? shortName!.trim()
      : name;

  /// Canonical route destination for navigation
  String get routeDestination {
    if (destination != null && destination!.trim().isNotEmpty) {
      return destination!.trim();
    }
    final s = slug.toLowerCase().trim();
    switch (s) {
      case 'admit-cards':
      case 'admit_cards':
        return '/updates?tab=admit_cards';
      case 'results':
        return '/updates?tab=results';
      case 'answer-keys':
      case 'answer_keys':
        return '/updates?tab=answer_keys';
      case 'syllabus':
        return '/updates?tab=syllabus';
      case 'articles':
        return '/more';
      case 'andaman-nicobar':
      case 'andaman':
        return '/jobs?category=andaman-nicobar';
      case 'ssc':
        return '/jobs?category=ssc';
      case 'railway':
        return '/jobs?category=railway';
      case 'banking':
        return '/jobs?category=banking';
      case 'police-defence':
      case 'police':
        return '/jobs?category=police-defence';
      default:
        return '/jobs?category=$s';
    }
  }

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF159B76);
    }
  }

  IconData get iconData {
    switch (icon.toLowerCase().trim()) {
      case 'work':
      case 'briefcase':
      case 'bag':
        return Icons.work_outline_rounded;
      case 'location_on':
      case 'mappin':
      case 'map_pin':
      case 'island':
        return Icons.location_on_outlined;
      case 'account_balance':
      case 'landmark':
      case 'govt':
      case 'central':
        return Icons.account_balance_outlined;
      case 'train':
      case 'railway':
      case 'metro':
        return Icons.train_outlined;
      case 'payments':
      case 'banknote':
      case 'bank':
      case 'banking':
      case 'rupee':
        return Icons.payments_outlined;
      case 'security':
      case 'shield':
      case 'police':
      case 'defence':
      case 'army':
        return Icons.security_rounded;
      case 'badge':
      case 'filetext':
      case 'file_text':
      case 'card':
        return Icons.badge_outlined;
      case 'emoji_events':
      case 'award':
      case 'trophy':
      case 'medal':
        return Icons.emoji_events_outlined;
      case 'fact_check':
      case 'checksquare':
      case 'check_square':
      case 'key':
        return Icons.fact_check_outlined;
      case 'menu_book':
      case 'bookopen':
      case 'book_open':
      case 'book':
      case 'syllabus':
        return Icons.menu_book_outlined;
      case 'article':
      case 'newspaper':
      case 'guide':
        return Icons.article_outlined;
      case 'school':
      case 'graduation':
        return Icons.school_outlined;
      case 'star':
        return Icons.star_outline_rounded;
      default:
        return Icons.category_outlined;
    }
  }
}
