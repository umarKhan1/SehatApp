import 'package:flutter_test/flutter_test.dart';

/// Helper to find widgets by text with retry logic
Future<Finder> findWithRetry(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pumpAndSettle();
    final finder = find.text(text);
    if (finder.evaluate().isNotEmpty) {
      return finder;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  throw Exception('Could not find widget with text: $text');
}

/// Helper to wait for a specific condition
Future<void> waitFor(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pumpAndSettle();
    if (condition()) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  throw Exception('Condition not met within timeout');
}

/// Helper to enter text with delay
Future<void> enterTextSlowly(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
