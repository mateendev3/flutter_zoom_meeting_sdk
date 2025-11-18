/// Flutter plugin for integrating Zoom MobileRTC SDK.
///
/// This plugin provides a bridge to the Zoom MobileRTC SDK, enabling Flutter
/// applications to join Zoom meetings on Android and iOS platforms.
///
/// ## Usage
///
/// ```dart
/// final zoomSdk = FlutterZoomMeetingSdk();
///
/// // Initialize the SDK with a JWT token
/// await zoomSdk.initialize(jwtToken: 'your_jwt_token');
///
/// // Join a meeting
/// await zoomSdk.joinMeeting(
///   meetingNumber: '1234567890',
///   displayName: 'John Doe',
/// );
/// ```
library;

import 'flutter_zoom_meeting_sdk_platform_interface.dart';

/// Main class for interacting with the Zoom MobileRTC SDK.
///
/// This class provides methods to initialize the Zoom SDK and join meetings.
/// You must call [initialize] before attempting to join any meetings.
///
/// Example:
/// ```dart
/// final zoomSdk = FlutterZoomMeetingSdk();
/// final result = await zoomSdk.initialize(jwtToken: 'your_token');
/// if (result?['status'] == 'success') {
///   await zoomSdk.joinMeeting(
///     meetingNumber: '1234567890',
///     displayName: 'User Name',
///   );
/// }
/// ```
class FlutterZoomMeetingSdk {
  /// Gets the platform version information.
  ///
  /// Returns a string containing the platform version (e.g., "Android 13" or "iOS 16.0").
  ///
  /// Returns:
  /// - A [Future] that completes with a platform version string, or `null` if unavailable.
  ///
  /// Example:
  /// ```dart
  /// final version = await zoomSdk.getPlatformVersion();
  /// print('Platform: $version'); // e.g., "Android 13"
  /// ```
  Future<String?> getPlatformVersion() {
    return FlutterZoomMeetingSdkPlatform.instance.getPlatformVersion();
  }

  /// Initializes the Zoom MobileRTC SDK with the provided JWT token.
  ///
  /// This method must be called before attempting to join any meetings.
  /// The initialization is asynchronous and may take a few seconds to complete.
  ///
  /// **Important**: You need a valid JWT token generated from your Zoom developer
  /// account credentials. See the [Zoom SDK documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started)
  /// for details on how to generate a JWT token.
  ///
  /// Parameters:
  /// - [jwtToken] (required): JWT token generated from your Zoom credentials.
  ///   This token is used to authenticate your app with Zoom's servers.
  /// - [domain] (optional): Zoom domain. Defaults to `'zoom.us'`.
  ///   Use a custom domain if your organization uses Zoom with a custom domain.
  /// - [enableLog] (optional): Enable SDK logging. Defaults to `true`.
  ///   Set to `false` to disable logging for production builds.
  /// - [enableDump] (optional): Enable crash dump generation. Defaults to `true`.
  ///   Useful for debugging but may be disabled in production.
  /// - [logSize] (optional): Maximum log file size in MB. Defaults to `5`.
  ///   Logs will be rotated when this size is reached.
  ///
  /// Returns:
  /// - A [Future] that completes with a [Map] containing:
  ///   - `status`: `"success"` if initialization succeeded, or error information if it failed.
  ///   - Additional error details if initialization failed.
  ///
  /// Throws:
  /// - Platform exceptions if the initialization fails at the native level.
  ///
  /// Example:
  /// ```dart
  /// final result = await zoomSdk.initialize(
  ///   jwtToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  ///   domain: 'zoom.us',
  ///   enableLog: true,
  /// );
  ///
  /// if (result?['status'] == 'success') {
  ///   print('SDK initialized successfully');
  /// } else {
  ///   print('Initialization failed: $result');
  /// }
  /// ```
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

  /// Joins a Zoom meeting with the specified parameters.
  ///
  /// This method opens the Zoom meeting UI and attempts to join the specified meeting.
  /// The meeting must already exist - this plugin does not create meetings.
  ///
  /// **Important**: You must call [initialize] successfully before calling this method.
  ///
  /// Parameters:
  /// - [meetingNumber] (required): The Zoom meeting number (e.g., "1234567890").
  ///   This is the numeric ID of the meeting you want to join.
  /// - [password] (optional): Meeting password if the meeting is password-protected.
  ///   Leave as `null` if the meeting doesn't require a password.
  /// - [displayName] (required): The display name that will be shown to other
  ///   participants in the meeting.
  ///
  /// Returns:
  /// - A [Future] that completes with a [Map] containing:
  ///   - `status`: `"success"` if the join request was accepted, or `"failure"` otherwise.
  ///   - `code`: The meeting error code (0 for success, non-zero for errors).
  ///
  /// Throws:
  /// - Platform exceptions if the join operation fails at the native level.
  /// - An error if the SDK is not initialized (call [initialize] first).
  ///
  /// Example:
  /// ```dart
  /// final result = await zoomSdk.joinMeeting(
  ///   meetingNumber: '1234567890',
  ///   password: 'optional_password',
  ///   displayName: 'John Doe',
  /// );
  ///
  /// if (result?['status'] == 'success') {
  ///   print('Joining meeting...');
  /// } else {
  ///   print('Failed to join: ${result?['code']}');
  /// }
  /// ```
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
