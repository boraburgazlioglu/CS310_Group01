import 'package:flutter/material.dart';

import '../utils/rehearsal_datetime_utils.dart';
import '../utils/text.dart';

class RehearsalTimeSummary extends StatelessWidget {
  final DateTime? startAt;
  final DateTime? endAt;

  const RehearsalTimeSummary({
    super.key,
    required this.startAt,
    required this.endAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          startAt == null
              ? 'No start time selected'
              : 'Start: ${RehearsalDateTimeUtils.formatDateTime(startAt!)}',
          style: AppTexts.bodyM,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          endAt == null
              ? 'No end time selected'
              : 'End: ${RehearsalDateTimeUtils.formatDateTime(endAt!)}',
          style: AppTexts.bodyM,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
