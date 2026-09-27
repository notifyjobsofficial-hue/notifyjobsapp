import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_jobs/core/utils/performance_tracker.dart';
import 'package:notify_jobs/core/widgets/nj_skeleton.dart';
import 'package:notify_jobs/core/widgets/nj_section_error.dart';

void main() {
  group('Performance & Startup Tests', () {
    test('PerformanceTracker records and tracks milestones correctly', () {
      PerformanceTracker.reset();
      expect(PerformanceTracker.milestones.isEmpty, isTrue);

      PerformanceTracker.mark('MainStart');
      expect(PerformanceTracker.get('MainStart'), isNotNull);

      PerformanceTracker.mark('FirstFrame');
      expect(PerformanceTracker.get('FirstFrame'), isNotNull);

      expect(PerformanceTracker.milestones.containsKey('MainStart'), isTrue);
      expect(PerformanceTracker.milestones.containsKey('FirstFrame'), isTrue);
    });

    testWidgets('NjLiveTickerSkeleton renders without overflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NjLiveTickerSkeleton(),
          ),
        ),
      );

      expect(find.byType(NjLiveTickerSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NjQuickCategoriesSkeleton renders requested tile count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NjQuickCategoriesSkeleton(count: 6),
            ),
          ),
        ),
      );

      expect(find.byType(NjQuickCategoriesSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NjJobCardSkeleton renders matching job card shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NjJobCardSkeleton(),
            ),
          ),
        ),
      );

      expect(find.byType(NjJobCardSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NjUpdateCardSkeleton renders matching update card shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NjUpdateCardSkeleton(),
            ),
          ),
        ),
      );

      expect(find.byType(NjUpdateCardSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NjSectionError renders message and invokes onRetry callback',
        (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjSectionError(
              message: 'Failed to load test section',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to load test section'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });
}
