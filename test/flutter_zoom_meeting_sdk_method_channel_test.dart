import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterZoomMeetingSdk platform = MethodChannelFlutterZoomMeetingSdk();
  const MethodChannel channel = MethodChannel('flutter_zoom_meeting_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return '42';
          case 'initialize':
            return {'status': 'success'};
          case 'joinMeeting':
            return {'status': 'success', 'code': 0};
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('initialize', () async {
    expect(
      await platform.initialize(jwtToken: 'token'),
      equals({'status': 'success'}),
    );
  });

  test('joinMeeting', () async {
    expect(
      await platform.joinMeeting(meetingNumber: '123456789', displayName: 'Flutter User'),
      equals({'status': 'success', 'code': 0}),
    );
  });
}
