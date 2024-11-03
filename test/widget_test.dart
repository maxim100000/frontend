// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// import 'package:pack/#main.dart';
import 'package:pack/go_main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
          // routerConfig: router,
          ),
    );
    // Open the drawer using swipe.
    // await tester.dragFrom(const Offset(0, 50), const Offset(300, 50));
    // await tester.pumpAndSettle();
    await tester.tap(find.text('вперед'));
    await tester.pumpAndSettle();
    await expectLater(find.byType(ElevatedButton), matchesGoldenFile('button.png'));
  });
}
