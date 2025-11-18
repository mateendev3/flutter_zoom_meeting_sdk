
import 'flutter_zoom_meeting_sdk_platform_interface.dart';

class FlutterZoomMeetingSdk {
  Future<String?> getPlatformVersion() {
    return FlutterZoomMeetingSdkPlatform.instance.getPlatformVersion();
  }

  Future<Map<String, dynamic>?> initialize({
    required String jwtToken,
    String domain = 'zoom.us',
    bool enableLog = true,
    bool enableDump = true,
    int logSize = 5,
  }) {
    return FlutterZoomMeetingSdkPlatform.instance.initialize(
      jwtToken: jwtToken,
      domain: domain,
      enableLog: enableLog,
      enableDump: enableDump,
      logSize: logSize,
    );
  }

  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingNumber,
    String? password,
    required String displayName,
  }) {
    return FlutterZoomMeetingSdkPlatform.instance.joinMeeting(
      meetingNumber: meetingNumber,
      password: password,
      displayName: displayName,
    );
  }
}
