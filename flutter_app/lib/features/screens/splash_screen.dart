import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Screen 1: Official Notify Jobs Splash Screen
/// Visual Architecture:
/// - Pure decorative background artwork (subtle government silhouette + bottom orange curves)
/// - SINGLE rendering of Notify Jobs logo, title, and tagline in Flutter
/// - Fully responsive across 320x568 to 412x915+ viewports
/// - Seamless native Android splash -> Flutter splash handoff
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Fast, seamless transition to Home without unnecessary waiting
    _navTimer = Timer(const Duration(milliseconds: 950), () {
      _navigateNext();
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (!mounted) return;
    try {
      if (GoRouter.maybeOf(context) != null) {
        context.go('/');
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        onTap: _navigateNext,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. High-fidelity Pure Decorative Background Artwork (No text, No duplicate logo)
              Image.asset(
                'assets/branding/splash_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // 2. Responsive Center Branding Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxHeight < 640;
                    final logoSize = isSmallScreen ? 88.0 : 104.0;
                    final titleSize = isSmallScreen ? 20.0 : 23.0;
                    final subtitleSize = isSmallScreen ? 12.0 : 13.5;
                    final verticalSpacing = isSmallScreen ? 14.0 : 20.0;

                    return Center(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Official Notify Jobs App Icon Badge
                                Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandOrange
                                            .withOpacity(0.18),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.asset(
                                      'assets/branding/notify_jobs_icon.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: verticalSpacing),

                                // Single Typography Branding: NOTIFY JOBS
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'NOTIFY ',
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'JOBS',
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.2,
                                        color: AppColors.brandOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Subtle Accent Divider
                                Container(
                                  width: 38,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandOrange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Single Clean Subtitle
                                Text(
                                  'Government Job Alerts & Exam Updates',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: subtitleSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
