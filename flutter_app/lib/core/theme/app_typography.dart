import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography Hierarchy for Notify Jobs (Specification 15)
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Major Heading (700)
  static const TextStyle majorHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
    letterSpacing: -0.4,
    height: 1.25,
  );

  // Section Heading (700)
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Card Title (600–700)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // Subtitle / Organization (500)
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    height: 1.35,
  );

  // Body Regular (400–500)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    height: 1.5,
  );

  // Body Medium (500)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
    height: 1.45,
  );

  // Compact Meta / Badges (500)
  static const TextStyle meta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    height: 1.3,
  );

  // Small Meta / Caption (500)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    height: 1.25,
  );

  // Button Text (600)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  // Aliases for Material 3 naming compatibility
  static const TextStyle headingSmall = majorHeading;
  static const TextStyle headingMedium = majorHeading;
  static const TextStyle titleSmall = subtitle;
  static const TextStyle titleMedium = cardTitle;
  static const TextStyle labelSmall = caption;
  static const TextStyle labelMedium = meta;
  static const TextStyle labelLarge = bodyMedium;
  static const TextStyle bodySmall = meta;
  static const TextStyle captionMedium = meta;
}
