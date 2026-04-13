// Basic Flutter widget smoke test for BandMate shell.

import 'package:flutter_test/flutter_test.dart';

import 'package:cs310_2026/main.dart';

void main() {
  testWidgets('BandMate app shows header and shell', (WidgetTester tester) async {
    await tester.pumpWidget(const BandmateApp());

    expect(find.text('BandMate'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
