import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_zoom_meeting_sdk_platform_interface.dart';

/// An implementation of [FlutterZoomMeetingSdkPlatform] that uses method channels.
class MethodChannelFlutterZoomMeetingSdk extends FlutterZoomMeetingSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_zoom_meeting_sdk');

  /// Initializes the Zoom SDK with provided parameters.
  ///
  /// [jwtToken] is the JWT required for authentication.
  /// [domain] defines the Zoom domain. Default is 'zoom.us'.
  /// [enableLog] enables logging if true. Defaults to true.
  /// [enableDump] enables dumping if true. Defaults to true.
  /// [logSize] specifies the log size, in MB. Default is 5.
  ///
  /// Returns a Map with initialization results, or null on error.
  @override
  Future<Map<String, dynamic>?> initialize({
    required String jwtToken,
    String domain = 'zoom.us',
    bool enableLog = true,
    bool enableDump = true,
    int logSize = 5,
  }) {
    return methodChannel.invokeMapMethod<String, dynamic>('initialize', {
      'jwtToken': jwtToken,
      'domain': domain,
      'enableLog': enableLog,
      'enableDump': enableDump,
      'logSize': logSize,
    });
  }

  /// Joins a Zoom meeting using the given parameters.
  ///
  /// [meetingNumber] is the ID of the meeting to join.
  /// [password] is the optional password for the meeting.
  /// [displayName] is the name that will be displayed in the meeting.
  ///
  /// Returns a Map with join results, or null on error.
  @override
  Future<Map<String, dynamic>?> joinMeeting({
    required String meetingNumber,
    String? password,
    required String displayName,
  }) {
    return methodChannel.invokeMapMethod<String, dynamic>('joinMeeting', {
      'meetingNumber': meetingNumber,
      'password': password,
      'displayName': displayName,
    });
  }
}
