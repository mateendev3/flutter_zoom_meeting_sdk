// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initialize test', (WidgetTester tester) async {
    final FlutterZoomMeetingSdk plugin = FlutterZoomMeetingSdk();
    // Note: This test requires a valid JWT token to actually initialize
    // For now, we just verify the plugin instance can be created
    expect(plugin, isNotNull);
  });
}
