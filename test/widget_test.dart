import 'package:flutter_test/flutter_test.dart';

import 'package:royal_charir_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoyalCharirApp());

    // Verify that our app starts with the dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
