import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Master 5-Destination Bottom Navigation Shell (Specification 17)
class MainShell extends StatelessWidget {
  final StatefulNavigationShell? navigationShell;
  final Widget? child;

  const MainShell({super.key, this.navigationShell, this.child});

  int _calculateSelectedIndex(BuildContext context) {
    if (navigationShell != null) {
      return navigationShell!.currentIndex;
    }
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/jobs')) return 1;
    if (location.startsWith('/updates')) return 2;
    if (location.startsWith('/saved')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0; // / is Home
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    if (navigationShell != null) {
      navigationShell!.goBranch(
        index,
        initialLocation: index == navigationShell!.currentIndex,
      );
      return;
    }
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/jobs');
        break;
      case 2:
        context.go('/updates');
        break;
      case 3:
        context.go('/saved');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'
      ),
      (
        icon: Icons.work_outline_rounded,
        activeIcon: Icons.work_rounded,
        label: 'Jobs'
      ),
      (
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
        label: 'Updates'
      ),
      (
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Saved'
      ),
      (
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'More'
      ),
    ];

    return Scaffold(
      body: navigationShell ?? child ?? const SizedBox.shrink(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () => _onItemTapped(index, context),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12 : 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.secondary.withOpacity(0.2)
                              : AppColors.secondarySoft)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 21,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF93C5FD)
                                  : AppColors.secondary)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.muted),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.button.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF93C5FD)
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
