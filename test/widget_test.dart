import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketplan/main.dart'; // Ensure this matches your app structure

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Test Home Screen')),
      ),
    ));

    expect(find.text('Test Home Screen'), findsOneWidget);
  });
}
