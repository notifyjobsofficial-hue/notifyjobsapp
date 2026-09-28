import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Screen 1: Official Notify Jobs Splash Screen
/// Visual direction matching approved visual design:
/// - Clean white/light canvas with subtle government watermark & smooth orange wave curves
/// - Official Notify Jobs logo (bell squircle badge + bold NJ + "NOTIFY JOBS")
/// - Orange accent divider bar + "Government Job Alerts & Exam Updates"
/// - Fast, lightweight startup transition directly to Home
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
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Fast transition to Home without artificial delay
    _navTimer = Timer(const Duration(milliseconds: 1100), () {
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
    context.go('/');
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
              // 1. High-fidelity Splash Background with government silhouette and orange curves
              Image.asset(
                'assets/branding/splash_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // 2. Center Branding Content with smooth entrance animation
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Official Notify Jobs Icon Badge
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.brandOrange.withOpacity(0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/branding/notify_jobs_icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Typography: NOTIFY JOBS
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'NOTIFY ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.4,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              Text(
                                'JOBS',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.4,
                                  color: AppColors.brandOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Orange Accent Divider Bar
                          Container(
                            width: 44,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.brandOrange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Subtitle
                          const Text(
                            'Government Job Alerts & Exam Updates',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
