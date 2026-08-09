import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hematyuk_finance/main.dart';

void main() {
  testWidgets('HematYuk app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HematYukApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), isNotNull);
  });
}
