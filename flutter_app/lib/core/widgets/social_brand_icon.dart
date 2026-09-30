import 'package:flutter/material.dart';

/// Supported social & messaging platforms with official brand assets
enum SocialPlatform {
  whatsapp,
  telegram;

  static SocialPlatform fromString(String? value) {
    final lower = value?.toLowerCase().trim() ?? '';
    if (lower.contains('tele')) {
      return SocialPlatform.telegram;
    }
    return SocialPlatform.whatsapp;
  }

  String get assetPath {
    switch (this) {
      case SocialPlatform.whatsapp:
        return 'assets/social/whatsapp.png';
      case SocialPlatform.telegram:
        return 'assets/social/telegram.png';
    }
  }

  String get displayName {
    switch (this) {
      case SocialPlatform.whatsapp:
        return 'WhatsApp';
      case SocialPlatform.telegram:
        return 'Telegram';
    }
  }

  Color brandColor(bool isDark) {
    switch (this) {
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SocialPlatform.telegram:
        return const Color(0xFF229ED9);
    }
  }

  Color defaultBgColor(bool isDark) {
    switch (this) {
      case SocialPlatform.whatsapp:
        return isDark
            ? const Color(0xFF16A34A).withOpacity(0.20)
            : const Color(0xFFDCFCE7);
      case SocialPlatform.telegram:
        return isDark
            ? const Color(0xFF0284C7).withOpacity(0.20)
            : const Color(0xFFE0F2FE);
    }
  }

  Color defaultBorderColor(bool isDark) {
    switch (this) {
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366).withOpacity(isDark ? 0.35 : 0.30);
      case SocialPlatform.telegram:
        return const Color(0xFF229ED9).withOpacity(isDark ? 0.35 : 0.30);
    }
  }
}

/// Centralized, high-fidelity Social Brand Icon for Notify Jobs
///
/// Strictly uses transparent official brand PNG assets (assets/social/whatsapp.png, assets/social/telegram.png).
/// Guarantees:
/// - Exact 28–32px icon size consistency across all screens
/// - Transparent PNG rendering with zero white square background artifacts
/// - Dark mode tint compliance without clipping or stretching
class SocialBrandIcon extends StatelessWidget {
  final SocialPlatform platform;
  final double size;
  final bool withBackground;
  final double? containerSize;
  final Color? backgroundColor;
  final bool isCircle;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const SocialBrandIcon({
    super.key,
    required this.platform,
    this.size = 28.0,
    this.withBackground = false,
    this.containerSize,
    this.backgroundColor,
    this.isCircle = true,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    this.border,
  });

  const SocialBrandIcon.whatsapp({
    super.key,
    this.size = 28.0,
    this.withBackground = false,
    this.containerSize,
    this.backgroundColor,
    this.isCircle = true,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    this.border,
  }) : platform = SocialPlatform.whatsapp;

  const SocialBrandIcon.telegram({
    super.key,
    this.size = 28.0,
    this.withBackground = false,
    this.containerSize,
    this.backgroundColor,
    this.isCircle = true,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    this.border,
  }) : platform = SocialPlatform.telegram;

  factory SocialBrandIcon.fromName(
    String name, {
    Key? key,
    double size = 28.0,
    bool withBackground = false,
    double? containerSize,
    Color? backgroundColor,
    bool isCircle = true,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return SocialBrandIcon(
      key: key,
      platform: SocialPlatform.fromString(name),
      size: size,
      withBackground: withBackground,
      containerSize: containerSize,
      backgroundColor: backgroundColor,
      isCircle: isCircle,
      borderRadius: borderRadius,
      padding: padding,
      boxShadow: boxShadow,
      border: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageWidget = Image.asset(
      platform.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: platform.displayName,
      errorBuilder: (context, error, stackTrace) => Icon(
        platform == SocialPlatform.whatsapp ? Icons.chat_bubble : Icons.send,
        size: size,
        color: platform.brandColor(isDark),
      ),
    );

    if (!withBackground) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: imageWidget),
      );
    }

    final double effectiveContainerSize =
        containerSize ?? (size + (size <= 24 ? 10 : 14));
    final Color effectiveBg =
        backgroundColor ?? platform.defaultBgColor(isDark);

    return Container(
      width: effectiveContainerSize,
      height: effectiveContainerSize,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            isCircle ? null : (borderRadius ?? BorderRadius.circular(10)),
        boxShadow: boxShadow,
        border: border,
      ),
      child: Center(child: imageWidget),
    );
  }
}
