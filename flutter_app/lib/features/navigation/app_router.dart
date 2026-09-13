import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/jobs_screen.dart';
import '../screens/updates_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/more_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/support_screen.dart';
import '../screens/notification_preferences_screen.dart';
import '../screens/maintenance_screen.dart';
import '../screens/update_required_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Master Application Router with Bottom Navigation Shell & Subroutes (Specification 6, 17, 90)
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ShellRoute for persistent 5-tab Bottom Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/jobs',
          name: 'jobs',
          pageBuilder: (context, state) {
            final category = state.uri.queryParameters['category'];
            return NoTransitionPage(
              child: JobsScreen(initialCategory: category),
            );
          },
        ),
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
        GoRoute(
          path: '/saved',
          name: 'saved',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SavedScreen(),
          ),
        ),
        GoRoute(
          path: '/more',
          name: 'more',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MoreScreen(),
          ),
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
    GoRoute(
      path: '/article/:id',
      name: 'article_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ArticleDetailScreen(id: id);
      },
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
  ],
);
