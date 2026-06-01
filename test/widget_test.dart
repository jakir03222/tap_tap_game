import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_tap_game/main.dart';

void main() {
  testWidgets('App launches splash screen', (tester) async {
    await tester.pumpWidget(const TapTapGameApp());
    expect(find.text('Tap Tap Game'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
