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
fvm flutter pub get
```

## Platform Setup

### Android

#### Prerequisites

Before using this plugin on Android, you need to set up the Zoom MobileRTC SDK locally:

1. **Download the MobileRTC bundle**  
   Download the prepared `mobilertc` and `mobilertc-repo` folders from our secure SharePoint link:  
   [https://algosoftcosa-my.sharepoint.com/:f:/g/personal/m_mehmood_algosoftco_com/EpZZI9of7QhOjrKJIzYLEF8B-E3OWnDNYAt1O6H3r0AOHw?e=zniJTc](https://algosoftcosa-my.sharepoint.com/:f:/g/personal/m_mehmood_algosoftco_com/EpZZI9of7QhOjrKJIzYLEF8B-E3OWnDNYAt1O6H3r0AOHw?e=zniJTc)

2. **Copy the folders into your _main_ application**  
   Place both folders directly inside `android/` of your app (not inside this plugin). After copying, you should have:

   ```
   <your-app>/android/mobilertc/
   <your-app>/android/mobilertc-repo/
   ```

   These folders already contain the required `mobilertc.aar`, `mobilertc-6.0.0.aar`, and `mobilertc-6.0.0.pom` files—no manual extraction or renaming necessary.

3. **Expose the repository to Flutter**: In your main app’s Gradle settings (e.g., root `android/build.gradle` or `build.gradle.kts`), add the local Maven path so Gradle can resolve `us.zoom:mobilertc:6.0.0`. Example (KTS):

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri(rootProject.file("mobilertc-repo")) }
        flatDir { dirs(rootProject.file("mobilertc")) }
    }
}
```

If you prefer Groovy:

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri(rootProject.file("mobilertc-repo")) }
        flatDir { dirs rootProject.file("mobilertc") }
    }
}
```

> **Tip:** The example app in this repo already contains these folders under `example/android/` and the above repository declarations in `example/android/build.gradle.kts`.

4. **Minimum SDK Version**: Ensure your `android/app/build.gradle` has `minSdkVersion` set to at least 28.

#### Required Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- OpenGL ES 2.0 feature for video rendering -->
<uses-feature android:glEsVersion="0x00020000"/>

<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Storage permissions -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>

<!-- Network permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- Phone state permission -->
<uses-permission android:name="android.permission.READ_PHONE_STATE" />

<!-- Bluetooth permissions -->
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

<!-- Audio/Video permissions -->
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />

<!-- System permissions -->
<uses-permission android:name="android.permission.BROADCAST_STICKY"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.REORDER_TASKS" />
```

> **Note**: Some permissions (like `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`, `POST_NOTIFICATIONS`) require runtime permission requests on Android 12+ (API 31+). Make sure to handle these in your app's permission handling logic.

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

## Running the example app

```bash
cd example
fvm flutter pub get
fvm flutter run
```

Make sure the `example/android/mobilertc*` folders still exist before running.

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
