import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_2026/utils/rehearsal_datetime_utils.dart';

void main() {
  group('RehearsalDateTimeUtils', () {
    test('formats date correctly', () {
      final dateTime = DateTime(2026, 5, 7, 9, 5);

      expect(RehearsalDateTimeUtils.formatDate(dateTime), '07/05/2026');
    });

    test('formats time correctly', () {
      final dateTime = DateTime(2026, 5, 7, 9, 5);

      expect(RehearsalDateTimeUtils.formatTime(dateTime), '09:05');
    });

    test('formats date and time together', () {
      final dateTime = DateTime(2026, 5, 7, 9, 5);

      expect(
        RehearsalDateTimeUtils.formatDateTime(dateTime),
        '07/05/2026 09:05',
      );
    });

    test('accepts a valid rehearsal time range', () {
      final startAt = DateTime(2026, 5, 7, 18, 0);
      final endAt = DateTime(2026, 5, 7, 20, 0);

      expect(RehearsalDateTimeUtils.isValidRange(startAt, endAt), true);
    });

    test('rejects null start or end times', () {
      final startAt = DateTime(2026, 5, 7, 18, 0);
      final endAt = DateTime(2026, 5, 7, 20, 0);

      expect(RehearsalDateTimeUtils.isValidRange(null, endAt), false);
      expect(RehearsalDateTimeUtils.isValidRange(startAt, null), false);
    });

    test('rejects end time before or equal to start time', () {
      final startAt = DateTime(2026, 5, 7, 18, 0);
      final sameEndAt = DateTime(2026, 5, 7, 18, 0);
      final earlierEndAt = DateTime(2026, 5, 7, 17, 0);

      expect(RehearsalDateTimeUtils.isValidRange(startAt, sameEndAt), false);
      expect(RehearsalDateTimeUtils.isValidRange(startAt, earlierEndAt), false);
    });
  });
}
