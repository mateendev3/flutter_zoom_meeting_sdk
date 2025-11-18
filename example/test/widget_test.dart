// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zoom_meeting_sdk_example/main.dart';

void main() {
  testWidgets('Verify app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app bar title is displayed
    expect(find.text('Zoom SDK sample'), findsOneWidget);

    // Verify that the initial log message is displayed
    expect(find.text('Not initialized'), findsOneWidget);

    // Verify that the initialize button is present
    expect(find.text('Initialize SDK'), findsOneWidget);

    // Verify that the join meeting button is present
    expect(find.text('Join meeting'), findsOneWidget);
  });
}
