import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_2026/widgets/rehearsal_time_summary.dart';

void main() {
  group('RehearsalTimeSummary', () {
    testWidgets('shows empty messages when no times are selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RehearsalTimeSummary(startAt: null, endAt: null),
          ),
        ),
      );

      expect(find.text('No start time selected'), findsOneWidget);
      expect(find.text('No end time selected'), findsOneWidget);
    });

    testWidgets('shows formatted start and end times when selected', (
      tester,
    ) async {
      final startAt = DateTime(2026, 5, 7, 18, 0);
      final endAt = DateTime(2026, 5, 7, 20, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RehearsalTimeSummary(startAt: startAt, endAt: endAt),
          ),
        ),
      );

      expect(find.text('Start: 07/05/2026 18:00'), findsOneWidget);
      expect(find.text('End: 07/05/2026 20:30'), findsOneWidget);
    });
  });
}
