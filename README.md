# flutter_zoom_meeting_sdk

A Flutter plugin that provides a bridge to the Zoom MobileRTC SDK, enabling Flutter applications to join Zoom meetings on Android and iOS platforms.

## Features

- ✅ Initialize Zoom SDK with JWT token
- ✅ Join Zoom meetings programmatically
- ✅ Support for meeting passwords
- ✅ Customizable display names
- ✅ Android fully supported
- ⚠️ iOS support (partial - platform version only)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_zoom_meeting_sdk: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android

#### Prerequisites

Before using this plugin on Android, you need to set up the Zoom MobileRTC SDK locally:

1. **Download the Zoom MobileRTC SDK** (version 6.0.0) from the [Zoom Developer Portal](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started)

2. **Set up the local Maven repository**:

   - Extract the downloaded SDK
   - Create the following directory structure in your project's `android/mobilertc-repo/` folder:
     ```
     android/mobilertc-repo/
     └── us/
         └── zoom/
             └── mobilertc/
                 └── 6.0.0/
                     ├── mobilertc-6.0.0.aar
                     └── mobilertc-6.0.0.pom
     ```
   - Copy the `mobilertc.aar` file from the downloaded SDK and rename it to `mobilertc-6.0.0.aar`
   - Create a `mobilertc-6.0.0.pom` file with the following content:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
         <modelVersion>4.0.0</modelVersion>
         <groupId>us.zoom</groupId>
         <artifactId>mobilertc</artifactId>
         <version>6.0.0</version>
         <packaging>aar</packaging>
         <name>Zoom MobileRTC</name>
         <description>Embedded Zoom Meeting SDK</description>
     </project>
     ```

3. **Copy the AAR for the embedded module**: Place the same `mobilertc.aar` file inside `android/mobilertc/mobilertc.aar`. The plugin’s Android module references this file directly when packaging the Flutter plugin.

4. **Minimum SDK Version**: Ensure your `android/app/build.gradle` has `minSdkVersion` set to at least 28.

#### Required Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

### iOS

⚠️ **Note**: iOS implementation is currently partial. Only platform version detection is available. Full meeting functionality for iOS is coming soon.

## Usage

### Import the package

```dart
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';
```

### Initialize the Zoom SDK

Before joining any meetings, you must initialize the SDK with a JWT token:

```dart
final zoomSdk = FlutterZoomMeetingSdk();

// Initialize with JWT token
final result = await zoomSdk.initialize(
  jwtToken: 'your_jwt_token_here',
  domain: 'zoom.us', // Optional, defaults to 'zoom.us'
  enableLog: true,    // Optional, defaults to true
  enableDump: true,   // Optional, defaults to true
  logSize: 5,         // Optional, defaults to 5
);

if (result?['status'] == 'success') {
  print('Zoom SDK initialized successfully');
} else {
  print('Initialization failed: $result');
}
```

**Important**: You need to generate a JWT token from your Zoom account credentials. See the [Zoom SDK documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started) for details.

### Join a Meeting

After initializing the SDK, you can join a meeting:

```dart
final result = await zoomSdk.joinMeeting(
  meetingNumber: '1234567890',
  password: 'optional_password', // Optional
  displayName: 'John Doe',
);

if (result?['status'] == 'success') {
  print('Joining meeting...');
} else {
  print('Failed to join: ${result?['code']}');
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_zoom_meeting_sdk/flutter_zoom_meeting_sdk.dart';

class ZoomMeetingPage extends StatefulWidget {
  @override
  _ZoomMeetingPageState createState() => _ZoomMeetingPageState();
}

class _ZoomMeetingPageState extends State<ZoomMeetingPage> {
  final _zoomSdk = FlutterZoomMeetingSdk();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeZoom();
  }

  Future<void> _initializeZoom() async {
    try {
      final result = await _zoomSdk.initialize(
        jwtToken: 'YOUR_JWT_TOKEN',
      );

      if (result?['status'] == 'success') {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _joinMeeting() async {
    if (!_isInitialized) {
      print('SDK not initialized');
      return;
    }

    try {
      final result = await _zoomSdk.joinMeeting(
        meetingNumber: '1234567890',
        displayName: 'Flutter User',
      );
      print('Join result: $result');
    } catch (e) {
      print('Join error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zoom Meeting')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isInitialized ? _joinMeeting : null,
          child: Text('Join Meeting'),
        ),
      ),
    );
  }
}
```

## API Reference

### `FlutterZoomMeetingSdk`

#### `initialize({required String jwtToken, String domain, bool enableLog, bool enableDump, int logSize})`

Initializes the Zoom SDK with the provided JWT token.

**Parameters:**

- `jwtToken` (required): JWT token generated from your Zoom credentials
- `domain` (optional): Zoom domain, defaults to `'zoom.us'`
- `enableLog` (optional): Enable logging, defaults to `true`
- `enableDump` (optional): Enable dump generation, defaults to `true`
- `logSize` (optional): Log size in MB, defaults to `5`

**Returns:** `Future<Map<String, dynamic>?>` with status information

#### `joinMeeting({required String meetingNumber, String? password, required String displayName})`

Joins a Zoom meeting.

**Parameters:**

- `meetingNumber` (required): The Zoom meeting number
- `password` (optional): Meeting password if required
- `displayName` (required): Display name to show in the meeting

**Returns:** `Future<Map<String, dynamic>?>` with join status and error code

#### `getPlatformVersion()`

Gets the platform version string.

**Returns:** `Future<String?>` with platform information

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.10.0`
- Android: Minimum SDK 28
- iOS: iOS 12.0+ (partial support)

## Important Notes

1. **SDK Files**: The Zoom MobileRTC SDK files are not included in this package due to size and licensing restrictions. You must download and set up the SDK files manually as described in the Android setup section.

2. **JWT Token**: You need a valid JWT token to initialize the SDK. Generate this from your Zoom developer account.

3. **Meeting Requirements**: The meeting must already exist. This plugin does not create meetings, only joins existing ones.

4. **iOS Support**: Full iOS support is in development. Currently, only platform version detection is available.

## Troubleshooting

### Android Build Errors

- **"Could not find mobilertc"**: Ensure you've set up the `mobilertc-repo` directory structure correctly as described in the Android setup section.

- **"SDK not initialized"**: Make sure you call `initialize()` before attempting to join a meeting, and that your JWT token is valid.

- **"Missing permissions"**: Ensure all required permissions are added to your `AndroidManifest.xml`.

### Common Issues

- **Initialization fails**: Verify your JWT token is valid and not expired
- **Cannot join meeting**: Check that the meeting number is correct and the meeting exists
- **Build errors**: Ensure your `minSdkVersion` is at least 28

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This plugin is provided as-is. Note that the Zoom MobileRTC SDK has its own license terms that you must comply with when using this plugin.

## Related Links

- [Zoom Developer Portal](https://marketplace.zoom.us/)
- [Zoom Android SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started)
- [Flutter Documentation](https://flutter.dev/docs)
