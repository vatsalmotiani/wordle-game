import 'package:flutter_test/flutter_test.dart';
import 'package:wordle_app/main.dart';

void main() {
  testWidgets('Wordle app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WordleApp());

    // Allow async initialization to complete
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('WORDLE'), findsOneWidget);
  });
}
