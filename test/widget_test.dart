import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:checkit/app.dart';

void main() {
  testWidgets('CheckIt app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CheckItApp()));

    expect(find.text('CheckIt'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
