import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Lightweight, responsive Markdown renderer for Article and Update bodies.
/// Supports Headings (#, ##, ###), Bullet Points (-, *), Numbered Lists (1.),
/// Bold (**text**), and clean paragraphs with appropriate typography.
class NjMarkdownView extends StatelessWidget {
  final String data;
  final TextStyle? baseStyle;

  const NjMarkdownView({
    super.key,
    required this.data,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBaseStyle = baseStyle ??
        AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.navy,
          height: 1.6,
        );

    final lines = data.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Heading 1 (# ...)
      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            line.substring(2).trim(),
            style: AppTypography.headingMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.navy,
              height: 1.3,
            ),
          ),
        ));
        continue;
      }

      // Heading 2 (## ...)
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.substring(3).trim(),
            style: AppTypography.headingSmall.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.navy,
              height: 1.3,
            ),
          ),
        ));
        continue;
      }

      // Heading 3 (### ...)
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.substring(4).trim(),
            style: AppTypography.titleMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.3,
            ),
          ),
        ));
        continue;
      }

      // Unordered list item (- or *)
      if (line.startsWith('- ') || line.startsWith('* ')) {
        final content = line.substring(2).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7, right: 10),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: RichText(
                  text: _parseInlineMarkdown(content, defaultBaseStyle, isDark),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Numbered list item (e.g. "1. ", "2. ")
      final numberMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line);
      if (numberMatch != null) {
        final numStr = numberMatch.group(1)!;
        final content = numberMatch.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  numStr,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: _parseInlineMarkdown(content, defaultBaseStyle, isDark),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Regular paragraph line with inline markdown support (**bold**, *italic*)
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: _parseInlineMarkdown(line, defaultBaseStyle, isDark),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Parses inline bold (**text**) and italic (*text*) syntax into TextSpans.
  TextSpan _parseInlineMarkdown(String text, TextStyle baseStyle, bool isDark) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*([^*]+)\*\*)|(\*([^*]+)\*)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(2) != null) {
        // Bold (**...**)
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.navy,
          ),
        ));
      } else if (match.group(4) != null) {
        // Italic (*...*)
        spans.add(TextSpan(
          text: match.group(4),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
