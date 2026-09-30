import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NjIconVariant {
  latestJobs,
  govtJobs,
  allGovtJobs,
  andamanJobs,
  allIndia,
  tenthPass,
  twelfthPass,
  graduate,
  admitCards,
  results,
  answerKeys,
  syllabus,
  examDates,
  articles,
  ssc,
  police,
  policeDefence,
  irbnPolice,
  defence,
  railway,
  banking,
  general,
}

/// Premium layered 3D-depth category icon container
/// Features top-light specular highlight, multi-stop gradient, layered ambient drop shadows,
/// and crisp floating glyphs.
class NjCategoryIcon extends StatelessWidget {
  final NjIconVariant? variant;
  final String? categorySlug;
  final IconData? icon;
  final Color? baseColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final List<Color>? customGradient;
  final Color? customShadowColor;

  const NjCategoryIcon({
    super.key,
    this.variant,
    this.categorySlug,
    this.icon,
    this.baseColor,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.borderRadius = 14.0,
    this.customGradient,
    this.customShadowColor,
  });

  /// Factory helper that automatically picks variant or colors based on slug/name
  static NjIconVariant resolveVariant(String? slugOrType) {
    if (slugOrType == null) {
      return NjIconVariant.general;
    }
    final s = slugOrType.toLowerCase().replaceAll('_', '-').trim();

    if (s.contains('irbn')) {
      return NjIconVariant.irbnPolice;
    }
    if (s.contains('police-defence') ||
        (s.contains('police') && s.contains('defence'))) {
      return NjIconVariant.policeDefence;
    }
    if (s.contains('police')) {
      return NjIconVariant.police;
    }
    if (s.contains('defence') || s.contains('defense') || s.contains('army')) {
      return NjIconVariant.defence;
    }
    if (s.contains('andaman') ||
        s == 'a&n' ||
        s == 'a-n' ||
        s.contains('nicobar')) {
      return NjIconVariant.andamanJobs;
    }
    if (s == 'latest' || s == 'latest-jobs' || s.contains('latest')) {
      return NjIconVariant.latestJobs;
    }
    if (s.contains('all-india') || s.contains('all india')) {
      return NjIconVariant.allIndia;
    }
    if (s.contains('10th')) {
      return NjIconVariant.tenthPass;
    }
    if (s.contains('12th')) {
      return NjIconVariant.twelfthPass;
    }
    if (s.contains('graduate') || s.contains('degree')) {
      return NjIconVariant.graduate;
    }
    if (s.contains('admit')) {
      return NjIconVariant.admitCards;
    }
    if (s.contains('result')) {
      return NjIconVariant.results;
    }
    if (s.contains('answer') || s.contains('key')) {
      return NjIconVariant.answerKeys;
    }
    if (s.contains('syllabus')) {
      return NjIconVariant.syllabus;
    }
    if (s.contains('exam') || s.contains('date')) {
      return NjIconVariant.examDates;
    }
    if (s.contains('article') || s.contains('guide')) {
      return NjIconVariant.articles;
    }
    if (s.contains('ssc')) {
      return NjIconVariant.ssc;
    }
    if (s.contains('railway') || s.contains('rrb')) {
      return NjIconVariant.railway;
    }
    if (s.contains('bank')) {
      return NjIconVariant.banking;
    }
    if (s.contains('all govt') || s == 'all-govt-jobs') {
      return NjIconVariant.allGovtJobs;
    }
    if (s.contains('govt') || s.contains('government') || s.contains('job')) {
      return NjIconVariant.govtJobs;
    }
    return NjIconVariant.general;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = variant ?? resolveVariant(categorySlug);
    final _IconSpec spec = _getSpec(resolved);

    final iconData = icon ?? spec.icon;

    List<Color> gradient = customGradient ?? spec.gradient;
    Color shadowColor = customShadowColor ?? spec.shadowColor;

    // If an explicit baseColor was passed and resolved is generic, build a dynamic 3-stop gradient
    if (baseColor != null &&
        customGradient == null &&
        variant == null &&
        resolved == NjIconVariant.general) {
      final hsl = HSLColor.fromColor(baseColor!);
      gradient = [
        hsl.withLightness((hsl.lightness * 1.18).clamp(0.0, 1.0)).toColor(),
        baseColor!,
        hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor(),
      ];
      shadowColor = baseColor!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          // Primary ambient volumetric colored glow
          BoxShadow(
            color: shadowColor.withOpacity(isDark ? 0.38 : 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          // Deep crisp grounding shadow
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.32 : 0.14),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Specular top-light reflection (creates 3D convex depth)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size * 0.45,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.22 : 0.32),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Outer subtle bevel border
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.16 : 0.24),
                  width: 1.0,
                ),
              ),
            ),
          ),
          // Floating crisp glyph
          Center(
            child: Icon(
              iconData,
              size: iconSize,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static _IconSpec _getSpec(NjIconVariant v) {
    switch (v) {
      case NjIconVariant.latestJobs:
        return const _IconSpec(
          icon: Icons.work_rounded,
          gradient: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          shadowColor: Color(0xFF059669),
        );
      case NjIconVariant.govtJobs:
        return const _IconSpec(
          icon: Icons.account_balance_rounded,
          gradient: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF0B2C5F)],
          shadowColor: Color(0xFF1D4ED8),
        );
      case NjIconVariant.allGovtJobs:
        return const _IconSpec(
          icon: Icons.account_balance_rounded,
          gradient: [Color(0xFFFBBF24), Color(0xFFD97706), Color(0xFF78350F)],
          shadowColor: Color(0xFFD97706),
        );
      case NjIconVariant.allIndia:
        return const _IconSpec(
          icon: Icons.public_rounded,
          gradient: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF075985)],
          shadowColor: Color(0xFF0284C7),
        );
      case NjIconVariant.tenthPass:
        return const _IconSpec(
          icon: Icons.workspace_premium_rounded,
          gradient: [Color(0xFFFB7185), Color(0xFFE11D48), Color(0xFF9F1239)],
          shadowColor: Color(0xFFE11D48),
        );
      case NjIconVariant.twelfthPass:
        return const _IconSpec(
          icon: Icons.menu_book_rounded,
          gradient: [Color(0xFFFB923C), Color(0xFFEA580C), Color(0xFF9A3412)],
          shadowColor: Color(0xFFEA580C),
        );
      case NjIconVariant.graduate:
        return const _IconSpec(
          icon: Icons.school_rounded,
          gradient: [Color(0xFF34D399), Color(0xFF059669), Color(0xFF064E3B)],
          shadowColor: Color(0xFF059669),
        );
      case NjIconVariant.andamanJobs:
        return const _IconSpec(
          icon: Icons.waves_rounded,
          gradient: [Color(0xFF0D9488), Color(0xFF0F766E), Color(0xFF115E59)],
          shadowColor: Color(0xFF0D9488),
        );
      case NjIconVariant.admitCards:
        return const _IconSpec(
          icon: Icons.badge_rounded,
          gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF5B21B6)],
          shadowColor: Color(0xFF7C3AED),
        );
      case NjIconVariant.results:
        return const _IconSpec(
          icon: Icons.emoji_events_rounded,
          gradient: [Color(0xFFFB923C), Color(0xFFEA580C), Color(0xFF9A3412)],
          shadowColor: Color(0xFFEA580C),
        );
      case NjIconVariant.answerKeys:
        return const _IconSpec(
          icon: Icons.fact_check_rounded,
          gradient: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)],
          shadowColor: Color(0xFF0284C7),
        );
      case NjIconVariant.syllabus:
        return const _IconSpec(
          icon: Icons.menu_book_rounded,
          gradient: [Color(0xFF64748B), Color(0xFF475569), Color(0xFF334155)],
          shadowColor: Color(0xFF475569),
        );
      case NjIconVariant.examDates:
        return const _IconSpec(
          icon: Icons.event_available_rounded,
          gradient: [Color(0xFFF43F5E), Color(0xFFE11D48), Color(0xFFBE123C)],
          shadowColor: Color(0xFFE11D48),
        );
      case NjIconVariant.articles:
        return const _IconSpec(
          icon: Icons.article_rounded,
          gradient: [Color(0xFF14B8A6), Color(0xFF0F766E), Color(0xFF134E4A)],
          shadowColor: Color(0xFF0F766E),
        );
      case NjIconVariant.ssc:
        return const _IconSpec(
          icon: Icons.account_balance_rounded,
          gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFB45309)],
          shadowColor: Color(0xFFF59E0B),
        );
      case NjIconVariant.police:
        return const _IconSpec(
          icon: Icons.shield_rounded,
          gradient: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
          shadowColor: Color(0xFF0284C7),
        );
      case NjIconVariant.policeDefence:
        return const _IconSpec(
          icon: Icons.shield_rounded,
          gradient: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          shadowColor: Color(0xFF1D4ED8),
        );
      case NjIconVariant.irbnPolice:
        return const _IconSpec(
          icon: Icons.local_police_rounded,
          gradient: [Color(0xFF1E3A8A), Color(0xFF172554), Color(0xFF0F172A)],
          shadowColor: Color(0xFF1E3A8A),
        );
      case NjIconVariant.defence:
        return const _IconSpec(
          icon: Icons.military_tech_rounded,
          gradient: [Color(0xFF15803D), Color(0xFF166534), Color(0xFF14532D)],
          shadowColor: Color(0xFF15803D),
        );
      case NjIconVariant.railway:
        return const _IconSpec(
          icon: Icons.directions_railway_rounded,
          gradient: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)],
          shadowColor: Color(0xFFDC2626),
        );
      case NjIconVariant.banking:
        return const _IconSpec(
          icon: Icons.payments_rounded,
          gradient: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF312E81)],
          shadowColor: Color(0xFF4F46E5),
        );
      case NjIconVariant.general:
        return const _IconSpec(
          icon: Icons.work_rounded,
          gradient: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
          shadowColor: Color(0xFF2563EB),
        );
    }
  }
}

/// Interactive elevated category tile for Home Screen Quick Categories.
///
/// Features:
/// - Soft 3D elevated NjCategoryIcon with specular highlight and ambient glow
/// - Spring micro-interaction: smooth press scale (0.94) for 120ms with haptic feedback
/// - 2-line centered, high-contrast typography with equal vertical alignment
class NjQuickCategoryTile extends StatefulWidget {
  final String label;
  final String slug;
  final IconData? icon;
  final Color? baseColor;
  final VoidCallback onTap;

  const NjQuickCategoryTile({
    super.key,
    required this.label,
    required this.slug,
    this.icon,
    this.baseColor,
    required this.onTap,
  });

  @override
  State<NjQuickCategoryTile> createState() => _NjQuickCategoryTileState();
}

class _NjQuickCategoryTileState extends State<NjQuickCategoryTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NjCategoryIcon(
              categorySlug: widget.slug,
              icon: widget.icon,
              baseColor: widget.baseColor,
              size: 44.0,
              iconSize: 22.0,
              borderRadius: 13.0,
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color:
                    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSpec {
  final IconData icon;
  final List<Color> gradient;
  final Color shadowColor;

  const _IconSpec({
    required this.icon,
    required this.gradient,
    required this.shadowColor,
  });
}
