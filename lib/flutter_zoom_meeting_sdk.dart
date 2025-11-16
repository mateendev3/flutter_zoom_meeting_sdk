
import 'flutter_zoom_meeting_sdk_platform_interface.dart';

class FlutterZoomMeetingSdk {
  Future<String?> getPlatformVersion() {
    return FlutterZoomMeetingSdkPlatform.instance.getPlatformVersion();
  }
}
