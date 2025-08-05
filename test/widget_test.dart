import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a basic widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Hello World'))),
      ),
    );

    // Verify the widget is displayed
    expect(find.text('Hello World'), findsOneWidget);
  });
}
