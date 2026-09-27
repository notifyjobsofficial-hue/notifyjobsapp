import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/content_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Compact Vertical Auto-Looping News Ticker for Live Updates (Specification 20, 52)
class NjVerticalLiveTicker extends StatefulWidget {
  final List<ContentModel> items;

  const NjVerticalLiveTicker({
    super.key,
    required this.items,
  });

  @override
  State<NjVerticalLiveTicker> createState() => _NjVerticalLiveTickerState();
}

class _NjVerticalLiveTickerState extends State<NjVerticalLiveTicker> {
  late final PageController _pageController;
  Timer? _timer;
  bool _isUserInteracting = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;

    _timer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (_isUserInteracting || !mounted || !_pageController.hasClients) return;
      final nextIndex = (_currentIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant NjVerticalLiveTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTap(ContentModel item) {
    HapticFeedback.selectionClick();
    String route = '/job/';
    if (item.contentType == 'article') {
      route = '/article/';
    } else if (item.contentType == 'admit_card' ||
        item.contentType == 'result' ||
        item.contentType == 'answer_key' ||
        item.contentType == 'syllabus') {
      route = '/update/';
    }
    context.push('$route${item.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      onPointerDown: (_) => setState(() => _isUserInteracting = true),
      onPointerUp: (_) => setState(() => _isUserInteracting = false),
      onPointerCancel: (_) => setState(() => _isUserInteracting = false),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Left Live Indicator Badge
              Container(
                width: 58,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.softGreen,
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF34D399)
                                : AppColors.primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.flash_on_rounded,
                      size: 15,
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),

              // Vertical Scrolling PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.items.length,
                  onPageChanged: (idx) {
                    setState(() => _currentIndex = idx);
                  },
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return InkWell(
                      onTap: () => _onItemTap(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.categoryDisplay,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.relativePublishedDate,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
