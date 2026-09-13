import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Master 5-Destination Bottom Navigation Shell (Specification 17)
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/jobs')) return 1;
    if (location.startsWith('/updates')) return 2;
    if (location.startsWith('/saved')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0; // / is Home
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
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
        icon: Icons.bolt_outlined,
        activeIcon: Icons.bolt_rounded,
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
      body: child,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.softGreen)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.muted),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: AppTypography.button.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
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
