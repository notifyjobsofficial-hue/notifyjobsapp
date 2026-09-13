import 'package:flutter/material.dart';

/// Category model for Notify Jobs (Specification 59, 129)
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String colorHex;
  final int order;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.colorHex,
    required this.order,
    this.isActive = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? 'Category',
      slug: map['slug']?.toString() ?? docId,
      icon: map['icon']?.toString() ?? 'work',
      colorHex: map['color']?.toString() ?? '#159B76',
      order: int.tryParse(map['order']?.toString() ?? '99') ?? 99,
      isActive: map['isActive'] != false,
    );
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
    switch (icon.toLowerCase()) {
      case 'work':
      case 'briefcase':
        return Icons.work_outline_rounded;
      case 'location_on':
      case 'mappin':
        return Icons.location_on_outlined;
      case 'account_balance':
      case 'landmark':
        return Icons.account_balance_outlined;
      case 'train':
        return Icons.train_outlined;
      case 'payments':
      case 'banknote':
        return Icons.payments_outlined;
      case 'security':
      case 'shield':
        return Icons.security_rounded;
      case 'badge':
      case 'filetext':
        return Icons.badge_outlined;
      case 'emoji_events':
      case 'award':
        return Icons.emoji_events_outlined;
      case 'fact_check':
      case 'checksquare':
        return Icons.fact_check_outlined;
      case 'menu_book':
      case 'bookopen':
        return Icons.menu_book_outlined;
      case 'article':
      case 'newspaper':
        return Icons.article_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
