import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_zoom_meeting_sdk_method_channel.dart';

abstract class FlutterZoomMeetingSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterZoomMeetingSdkPlatform.
  FlutterZoomMeetingSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterZoomMeetingSdkPlatform _instance = MethodChannelFlutterZoomMeetingSdk();

  /// The default instance of [FlutterZoomMeetingSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterZoomMeetingSdk].
  static FlutterZoomMeetingSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterZoomMeetingSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterZoomMeetingSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> initialize({
    required String jwtToken,
    String domain = 'zoom.us',
    bool enableLog = true,
    bool enableDump = true,
    int logSize = 5,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingNumber,
    String? password,
    required String displayName,
  }) {
    throw UnimplementedError('joinMeeting() has not been implemented.');
  }
}
