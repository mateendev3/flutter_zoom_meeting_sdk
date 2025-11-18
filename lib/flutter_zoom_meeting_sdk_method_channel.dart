import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_zoom_meeting_sdk_platform_interface.dart';

/// An implementation of [FlutterZoomMeetingSdkPlatform] that uses method channels.
class MethodChannelFlutterZoomMeetingSdk extends FlutterZoomMeetingSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_zoom_meeting_sdk');

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
