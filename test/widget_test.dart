import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('Tic Tac Toe UI test', (WidgetTester tester) async {
    // تشغيل التطبيق.
    await tester.pumpWidget(const SimpleTicTacToeApp());

    // التحقق من وجود عنوان التطبيق.
    expect(find.text('🎮 Tic Tac Toe - Simple'), findsOneWidget);

    // انتظار رسم الشاشة.
    await tester.pumpAndSettle();

    // التأكد من وجود 9 مربعات (شبكة اللعبة).
    final gameTiles = find.byType(GestureDetector);
    expect(gameTiles, findsNWidgets(9));

    // الضغط على أول مربع.
    await tester.tap(gameTiles.at(0));
    await tester.pump();

    // التأكد من ظهور X بعد الضغط.
    expect(find.text('X'), findsOneWidget);

    // الضغط على زر إعادة اللعب إذا ظهر.
    final resetButton = find.text('إعادة');
    if (resetButton.evaluate().isNotEmpty) {
      await tester.tap(resetButton);
      await tester.pump();
      expect(find.text('X'), findsNothing);
    }
  });
}
