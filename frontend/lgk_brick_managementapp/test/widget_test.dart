import 'package:flutter_test/flutter_test.dart';
import 'package:lgk_brick_managementapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('LGK Brick Management App'), findsOneWidget);
  });
}
