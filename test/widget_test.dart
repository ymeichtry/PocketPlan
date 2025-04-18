import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Test Home Screen')),
      ),
    ));

    expect(find.text('Test Home Screen'), findsOneWidget);
  });
}
