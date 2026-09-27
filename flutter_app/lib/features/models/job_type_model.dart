import 'package:flutter/material.dart';

/// Dynamic Job / Employment Type Model (v1.1)
class JobTypeModel {
  final String id;
  final String name;
  final String shortName;
  final String slug;
  final String description;
  final int order;
  final bool isActive;
  final String colorToken;

  const JobTypeModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.slug,
    this.description = '',
    this.order = 0,
    this.isActive = true,
    this.colorToken = 'emerald',
  });

  factory JobTypeModel.fromMap(Map<String, dynamic> map, String docId) {
    return JobTypeModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? 'Government',
      shortName:
          map['shortName']?.toString() ?? map['name']?.toString() ?? 'Govt',
      slug: map['slug']?.toString() ?? docId.toLowerCase(),
      description: map['description']?.toString() ?? '',
      order: int.tryParse(map['order']?.toString() ?? '0') ?? 0,
      isActive: map['isActive'] != false,
      colorToken: map['colorToken']?.toString() ?? 'emerald',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'slug': slug,
        'description': description,
        'order': order,
        'isActive': isActive,
        'colorToken': colorToken,
      };

  Color get badgeBgColor {
    switch (colorToken.toLowerCase()) {
      case 'blue':
        return const Color(0xFFEFF6FF); // blue-50
      case 'amber':
        return const Color(0xFFFFFBEB); // amber-50
      case 'purple':
        return const Color(0xFFFAF5FF); // purple-50
      case 'cyan':
        return const Color(0xFFECFEFF); // cyan-50
      case 'rose':
        return const Color(0xFFFFF1F2); // rose-50
      case 'slate':
        return const Color(0xFFF1F5F9); // slate-100
      case 'emerald':
      default:
        return const Color(0xFFECFDF5); // emerald-50
    }
  }

  Color get badgeTextColor {
    switch (colorToken.toLowerCase()) {
      case 'blue':
        return const Color(0xFF1D4ED8); // blue-700
      case 'amber':
        return const Color(0xFFB45309); // amber-700
      case 'purple':
        return const Color(0xFF7E22CE); // purple-700
      case 'cyan':
        return const Color(0xFF0E7490); // cyan-700
      case 'rose':
        return const Color(0xFFBE123C); // rose-700
      case 'slate':
        return const Color(0xFF334155); // slate-700
      case 'emerald':
      default:
        return const Color(0xFF047857); // emerald-700
    }
  }

  Color get badgeBorderColor {
    switch (colorToken.toLowerCase()) {
      case 'blue':
        return const Color(0xFFBFDBFE); // blue-200
      case 'amber':
        return const Color(0xFFFDE68A); // amber-200
      case 'purple':
        return const Color(0xFFE9D5FF); // purple-200
      case 'cyan':
        return const Color(0xFFA5F3FC); // cyan-200
      case 'rose':
        return const Color(0xFFFECDD3); // rose-200
      case 'slate':
        return const Color(0xFFCBD5E1); // slate-300
      case 'emerald':
      default:
        return const Color(0xFFA7F3D0); // emerald-200
    }
  }

  static const List<JobTypeModel> defaultJobTypes = [
    JobTypeModel(
      id: 'government',
      name: 'Government Employment',
      shortName: 'Govt',
      slug: 'government',
      description: 'Permanent central or state government post',
      order: 1,
      isActive: true,
      colorToken: 'emerald',
    ),
    JobTypeModel(
      id: 'private',
      name: 'Private Sector',
      shortName: 'Private',
      slug: 'private',
      description: 'Corporate, local enterprise, or island private job',
      order: 2,
      isActive: true,
      colorToken: 'blue',
    ),
    JobTypeModel(
      id: 'contractual',
      name: 'Contractual Employment',
      shortName: 'Contractual',
      slug: 'contractual',
      description: 'Fixed term or contract basis recruitment',
      order: 3,
      isActive: true,
      colorToken: 'amber',
    ),
    JobTypeModel(
      id: 'temporary',
      name: 'Temporary Post',
      shortName: 'Temporary',
      slug: 'temporary',
      description: 'Short term urgent requirement',
      order: 4,
      isActive: true,
      colorToken: 'purple',
    ),
    JobTypeModel(
      id: 'apprentice',
      name: 'Apprenticeship / Training',
      shortName: 'Apprentice',
      slug: 'apprentice',
      description: 'Stipendiary apprentice or trade trainee post',
      order: 5,
      isActive: true,
      colorToken: 'cyan',
    ),
    JobTypeModel(
      id: 'internship',
      name: 'Internship',
      shortName: 'Internship',
      slug: 'internship',
      description: 'Student or graduate training position',
      order: 6,
      isActive: true,
      colorToken: 'rose',
    ),
    JobTypeModel(
      id: 'walkin',
      name: 'Walk-in Interview',
      shortName: 'Walk-in',
      slug: 'walkin',
      description: 'Direct walk-in selection drive',
      order: 7,
      isActive: true,
      colorToken: 'slate',
    ),
  ];
}
