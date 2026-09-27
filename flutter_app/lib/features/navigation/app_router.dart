import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/jobs_screen.dart';
import '../screens/updates_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/more_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/update_detail_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/support_screen.dart';
import '../screens/notification_preferences_screen.dart';
import '../screens/notification_inbox_screen.dart';
import '../screens/maintenance_screen.dart';
import '../screens/update_required_screen.dart';
import '../screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Master Application Router with Bottom Navigation Shell & Subroutes (Specification 6, 17, 90)
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // StatefulShellRoute for persistent 5-tab Bottom Navigation (Zero reload, preserves scroll/state)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              name: 'jobs',
              pageBuilder: (context, state) {
                final category = state.uri.queryParameters['category'];
                final qualification =
                    state.uri.queryParameters['qualification'];
                final filter = state.uri.queryParameters['filter'];
                return NoTransitionPage(
                  child: JobsScreen(
                    initialCategory: category,
                    initialQualification: qualification,
                    initialFilter: filter,
                  ),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/updates',
              name: 'updates',
              pageBuilder: (context, state) {
                final tab = state.uri.queryParameters['tab'];
                return NoTransitionPage(
                  child: UpdatesScreen(initialTab: tab),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SavedScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MoreScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Push Sub-routes (Full Screen overlays)
    GoRoute(
      path: '/job/:id',
      name: 'job_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return JobDetailScreen(id: id);
      },
    ),
    // Standard /jobs/:id deep link alias
    GoRoute(
      path: '/jobs/:id',
      name: 'jobs_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return JobDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/article/:id',
      name: 'article_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ArticleDetailScreen(id: id);
      },
    ),
    // /update/:id — Dedicated for Admit Cards, Results, Answer Keys, Syllabus detail views
    GoRoute(
      path: '/update/:id',
      name: 'update_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UpdateDetailScreen(id: id);
      },
    ),
    // Dedicated exam update deep links
    GoRoute(
      path: '/admit-card/:id',
      name: 'admit_card_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UpdateDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/result/:id',
      name: 'result_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UpdateDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/answer-key/:id',
      name: 'answer_key_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UpdateDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/syllabus/:id',
      name: 'syllabus_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UpdateDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/onboarding',
      redirect: (context, state) => '/',
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/andaman',
      name: 'andaman_jobs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          const JobsScreen(initialCategory: 'andaman-nicobar'),
    ),
    GoRoute(
      path: '/support',
      name: 'support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationInboxScreen(),
    ),
    GoRoute(
      path: '/notification-preferences',
      name: 'notification_preferences',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationPreferencesScreen(),
    ),
    GoRoute(
      path: '/maintenance',
      name: 'maintenance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: '/update-required',
      name: 'update_required',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UpdateRequiredScreen(),
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/pro',
      redirect: (context, state) => '/',
    ),
  ],
);
