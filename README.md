# flutter_zoom_meeting_sdk

A Flutter plugin that provides a bridge to the Zoom MobileRTC SDK, enabling Flutter applications to join Zoom meetings on Android and iOS platforms.

## Features

- ✅ Initialize Zoom SDK with JWT token
- ✅ Join Zoom meetings programmatically
- ✅ Support for meeting passwords
- ✅ Customizable display names
- ✅ Android fully supported
- ✅ iOS fully supported

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

#### Prerequisites

Before using this plugin on iOS, you need to set up the Zoom MobileRTC SDK locally:

#### Step 1: Download the Zoom iOS SDK

1. Go to the [Zoom Developer Portal](https://marketplace.zoom.us/docs/sdk/native-sdks/ios/getting-started)
2. Download the **Zoom MobileRTC SDK for iOS** (usually a `.zip` file)
3. Extract the downloaded ZIP file

Inside the extracted SDK package, you'll typically find:

- A `lib/` directory containing the frameworks and bundle
- Example projects and documentation

#### Step 2: Locate the Required SDK Files

From the extracted SDK package, you need these 4 files (usually found in the `lib/` directory):

- `MobileRTC.xcframework` (main framework)
- `MobileRTCScreenShare.xcframework` (screen sharing framework)
- `zoomcml.xcframework` (communication framework)
- `MobileRTCResources.bundle` (resources bundle)

**Note**: The exact location may vary by SDK version. Look for a `lib/` or `frameworks/` folder in the extracted package.

#### Step 3: Copy SDK Files to Your Flutter App

1. Navigate to your Flutter app's `ios/` directory:

   ```bash
   cd <your-flutter-app>/ios
   ```

2. Create a `lib/` directory inside `ios/` (if it doesn't exist):

   ```bash
   mkdir -p lib
   ```

3. Copy the 4 SDK files into `ios/lib/`:

   ```bash
   # Copy from wherever you extracted the SDK
   cp /path/to/extracted-sdk/lib/MobileRTC.xcframework ios/lib/
   cp /path/to/extracted-sdk/lib/MobileRTCScreenShare.xcframework ios/lib/
   cp /path/to/extracted-sdk/lib/zoomcml.xcframework ios/lib/
   cp /path/to/extracted-sdk/lib/MobileRTCResources.bundle ios/lib/
   ```

   Your directory structure should now look like this:

   ```
   <your-flutter-app>/
     └── ios/
         ├── lib/
         │   ├── MobileRTC.xcframework/
         │   ├── MobileRTCScreenShare.xcframework/
         │   ├── zoomcml.xcframework/
         │   └── MobileRTCResources.bundle/
         ├── Runner/
         ├── Podfile
         └── ...
   ```

#### Step 4: Configure Xcode Project

1. **Open your iOS project in Xcode**:

   ```bash
   open ios/Runner.xcworkspace
   ```

   ⚠️ **Important**: Always open `.xcworkspace`, not `.xcodeproj`

2. **Configure Framework Search Paths**:

   - Still in the **Runner** target's **Build Settings** tab
   - In the search bar, type: `Framework Search Paths`
   - Double-click the **Framework Search Paths** row (under "Search Paths")
   - Click the **+** button
   - Add: `$(SRCROOT)/lib`
   - Ensure it's set to **recursive** (the folder icon should show a blue folder, not yellow)
   - Click **Done**

3. **Add MobileRTCResources.bundle to "Copy Bundle Resources"**:

   - Still in **Build Phases** tab
   - Expand **Copy Bundle Resources**
   - Click the **+** button
   - Click **Add Other...** → **Add Files...**
   - Navigate to `ios/lib/` and select `MobileRTCResources.bundle`
   - Click **Add**
   - Copy Items if needed (Create folder reference)
   - Verify `MobileRTCResources.bundle` appears in the list

4. **Add Frameworks to "Embed Frameworks"** (Required for runtime):
   - Still in **Build Phases** tab
   - Expand **Embed Frameworks**
   - Click the **+** button
   - Select all three frameworks:
     - `MobileRTC.xcframework`
     - `MobileRTCScreenShare.xcframework`
     - `zoomcml.xcframework`
   - Click **Add**
   - Ensure all three are set to **Code Sign On Copy** (check the checkbox)
   - Verify all three frameworks appear in the list

#### Step 5: Configure Podfile (Required)

To ensure the plugin can find the frameworks during compilation, add a `post_install` hook to your `ios/Podfile`:

1. Open `ios/Podfile` and ensure the minimum iOS version is set:

   ```ruby
   platform :ios, '13.0'
   ```

2. Add a `post_install` hook at the end of the Podfile (before the final `end`):

   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)

       # Configure framework search path and link frameworks for flutter_zoom_meeting_sdk plugin
       if target.name == 'flutter_zoom_meeting_sdk'
         # Get the absolute path to ios/lib/ directory
         ios_dir = File.dirname(installer.sandbox.root)
         lib_path = File.join(ios_dir, 'lib')

         # Add framework search paths
         target.build_configurations.each do |config|
           config.build_settings['FRAMEWORK_SEARCH_PATHS'] ||= ['$(inherited)']
           config.build_settings['FRAMEWORK_SEARCH_PATHS'] << "\"#{lib_path}\""

           # Add Swift import paths
           config.build_settings['SWIFT_INCLUDE_PATHS'] ||= ['$(inherited)']
           config.build_settings['SWIFT_INCLUDE_PATHS'] << "\"#{lib_path}\""
         end

         # Add frameworks to the plugin target's "Link Binary With Libraries" phase
         frameworks_group = installer.pods_project.frameworks_group
         frameworks_build_phase = target.frameworks_build_phase

         ['MobileRTC', 'MobileRTCScreenShare', 'zoomcml'].each do |framework_name|
           framework_path = File.join(lib_path, "#{framework_name}.xcframework")

           if File.exist?(framework_path)
             # Create file reference
             framework_ref = frameworks_group.new_file(framework_path)
             framework_ref.name = "#{framework_name}.xcframework"

             # Add to frameworks build phase
             frameworks_build_phase.add_file_reference(framework_ref)

             puts "Added #{framework_name}.xcframework to flutter_zoom_meeting_sdk target"
           else
             puts "WARNING: #{framework_path} not found!"
           end
         end

         puts "Configured flutter_zoom_meeting_sdk:"
         puts "  FRAMEWORK_SEARCH_PATHS: #{lib_path}"
         puts "  SWIFT_INCLUDE_PATHS: #{lib_path}"
       end
     end
   end
   ```

   This hook:

   - Configures framework search paths so the plugin can find the Zoom SDK frameworks
   - Adds Swift import paths for module resolution
   - Automatically links the frameworks to the plugin target
   - Provides helpful logging during `pod install`

3. Run `pod install` in the `ios/` directory:

   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Important**: After running `pod install`, close Xcode completely and reopen `ios/Runner.xcworkspace` to ensure the changes take effect.

#### Required Permissions

Add the following entries to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera to join Zoom meetings.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone to join Zoom meetings.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to share content in Zoom meetings.</string>
```

#### App Lifecycle Integration

The Zoom SDK requires app lifecycle notifications. Update your `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import MobileRTC

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    MobileRTC.shared().appWillResignActive()
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    MobileRTC.shared().appDidBecomeActive()
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    MobileRTC.shared().appDidEnterBackgroud()
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    MobileRTC.shared().appWillTerminate()
  }
}
```

> **Note**: The example app in this repo already contains these configurations under `example/ios/`.

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
- iOS: iOS 13.0+

## Important Notes

1. **SDK Files**: The Zoom MobileRTC SDK files are not included in this package due to size and licensing restrictions. You must download and set up the SDK files manually as described in the Android setup section.

2. **JWT Token**: You need a valid JWT token to initialize the SDK. Generate this from your Zoom developer account.

3. **Meeting Requirements**: The meeting must already exist. This plugin does not create meetings, only joins existing ones.

4. **iOS SDK Files**: The Zoom MobileRTC SDK files are not included in this package due to size and licensing restrictions. You must download and set up the SDK files manually as described in the iOS setup section.

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
