import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_jobs/core/widgets/nj_badge.dart';
import 'package:notify_jobs/core/widgets/nj_button.dart';
import 'package:notify_jobs/core/widgets/nj_card.dart';
import 'package:notify_jobs/core/widgets/nj_status_badge.dart';

void main() {
  group('Core Widget Rendering Tests', () {
    testWidgets('NjButton renders with correct label and executes callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjButton(
              label: 'Apply Online',
              icon: Icons.open_in_new,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Apply Online'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);

      await tester.tap(find.text('Apply Online'));
      expect(pressed, isTrue);
    });

    testWidgets('NjBadge renders label with appropriate styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NjBadge(
              label: 'Latest Job',
              variant: NjBadgeVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Latest Job'), findsOneWidget);
    });

    testWidgets('NjStatusBadge renders Open when deadline in future',
        (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 10));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjStatusBadge(lastDate: futureDate),
          ),
        ),
      );

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('NjStatusBadge renders Closed when deadline has passed',
        (WidgetTester tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NjStatusBadge(lastDate: pastDate),
          ),
        ),
      );

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('NjCard renders child inside decorated container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NjCard(
              child: Text('Card Content Test'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });
  });
}
