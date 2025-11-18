import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk_platform_interface.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterZoomMeetingSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterZoomMeetingSdkPlatform {

  @override
  Future<Map<String, dynamic>?> initialize({
    required String jwtToken,
    String domain = 'zoom.us',
    bool enableLog = true,
    bool enableDump = true,
    int logSize = 5,
  }) {
    return Future.value({'status': 'init'});
  }

  @override
  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingNumber,
    String? password,
    required String displayName,
  }) {
    return Future.value({'status': 'join'});
  }
}

void main() {
  final FlutterZoomMeetingSdkPlatform initialPlatform = FlutterZoomMeetingSdkPlatform.instance;

  test('$MethodChannelFlutterZoomMeetingSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterZoomMeetingSdk>());
  });

  test('initialize forwards to platform', () async {
    FlutterZoomMeetingSdk flutterZoomMeetingSdkPlugin = FlutterZoomMeetingSdk();
    MockFlutterZoomMeetingSdkPlatform fakePlatform = MockFlutterZoomMeetingSdkPlatform();
    FlutterZoomMeetingSdkPlatform.instance = fakePlatform;

    expect(
      await flutterZoomMeetingSdkPlugin.initialize(jwtToken: 'token'),
      equals({'status': 'init'}),
    );
  });

  test('joinMeeting forwards to platform', () async {
    FlutterZoomMeetingSdk flutterZoomMeetingSdkPlugin = FlutterZoomMeetingSdk();
    MockFlutterZoomMeetingSdkPlatform fakePlatform = MockFlutterZoomMeetingSdkPlatform();
    FlutterZoomMeetingSdkPlatform.instance = fakePlatform;

    expect(
      await flutterZoomMeetingSdkPlugin.joinMeeting(meetingNumber: '123', displayName: 'Tester'),
      equals({'status': 'join'}),
    );
  });
}
