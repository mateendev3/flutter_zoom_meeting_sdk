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

  /// Initializes the Zoom MobileRTC SDK on the platform.
  ///
  /// [jwtToken]: A valid JWT token generated from the Zoom developer account.
  /// [domain]: The Zoom domain to use, defaults to 'zoom.us'.
  /// [enableLog]: If true, enables SDK logging, defaults to true.
  /// [enableDump]: If true, enables crash dump generation, defaults to true.
  /// [logSize]: The maximum size of log files in MB, defaults to 5.
  ///
  /// Returns a [Future] that resolves with a [Map] containing:
  ///   - 'status': 'success' or error code if failed.
  ///   - Additional error details if initialization fails.
  ///
  /// Throws [UnimplementedError] if not overridden by the platform implementation.
  Future<Map<String, dynamic>?> initialize({
    required String jwtToken,
    String domain = 'zoom.us',
    bool enableLog = true,
    bool enableDump = true,
    int logSize = 5,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Joins a Zoom meeting with the given parameters.
  ///
  /// [meetingNumber]: The Zoom meeting number (required).
  /// [password]: The meeting password, if applicable (optional).
  /// [displayName]: The display name to use in the meeting (required).
  ///
  /// Returns a [Future] that resolves with a [Map] containing:
  ///   - 'status': 'success' if joined, otherwise error information.
  ///   - 'code': Numeric meeting join result code (0 for success).
  ///
  /// Throws [UnimplementedError] if not overridden by the platform implementation.
  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingNumber,
    String? password,
    required String displayName,
  }) {
    throw UnimplementedError('joinMeeting() has not been implemented.');
  }
}
