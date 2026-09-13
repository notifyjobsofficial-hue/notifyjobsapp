import 'package:flutter/material.dart';

/// Centralized Design System Colors for Notify Jobs (Specification 14 & 128)
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF159B76);
  static const Color primaryDark = Color(0xFF117A5E);
  static const Color primaryLight = Color(0xFFE6F7F2);
  static const Color softGreen = Color(0xFFECFDF5);
  static const Color softMint = Color(0xFFE0F2FE);

  // Neutral Palette (Light)
  static const Color navy = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF475569);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Functional / Semantic Palette
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFEFF6FF);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF5F3FF);

  // Dark Theme Palette (Specification 102)
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF151F32);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF26354A);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Semantic Aliases
  static const Color primarySubtle = softGreen;
  static const Color textPrimary = navy;
  static const Color textSecondary = secondaryText;
  static const Color textDisabled = muted;
}
