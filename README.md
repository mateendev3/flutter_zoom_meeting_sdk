# flutter_zoom_meeting_sdk

A Flutter plugin that provides a bridge to the Zoom MobileRTC SDK, enabling Flutter applications to join Zoom meetings on Android and iOS platforms.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Platform Setup](#platform-setup)
  - [Android](#android)
  - [iOS](#ios)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Requirements](#requirements)
- [Important Notes](#important-notes)
- [Troubleshooting](#troubleshooting)
- [Running the Example App](#running-the-example-app)
- [Contributing](#contributing)
- [License](#license)
- [Related Links](#related-links)

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
  flutter_zoom_meeting_sdk: ^1.0.2
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

Before using this plugin on iOS, you need to set up the Zoom MobileRTC SDK locally.

> **Setup Checklist**: After completing all steps, verify:
>
> - ✅ All 4 SDK files are in `ios/lib/`
> - ✅ Framework Search Paths configured in Xcode
> - ✅ MobileRTCResources.bundle in Copy Bundle Resources
> - ✅ Three frameworks in Embed Frameworks phase
> - ✅ Podfile `post_install` hook configured
> - ✅ `pod install` completed successfully
> - ✅ AppDelegate lifecycle methods implemented
> - ✅ Info.plist permissions added

#### Step 1: Download the Zoom iOS SDK

1. **Download the iOS SDK files**  
   Download the prepared iOS SDK files from our secure SharePoint link:  
   [https://algosoftcosa-my.sharepoint.com/:f:/g/personal/m_mehmood_algosoftco_com/EpZZI9of7QhOjrKJIzYLEF8B-E3OWnDNYAt1O6H3r0AOHw?e=zniJTc](https://algosoftcosa-my.sharepoint.com/:f:/g/personal/m_mehmood_algosoftco_com/EpZZI9of7QhOjrKJIzYLEF8B-E3OWnDNYAt1O6H3r0AOHw?e=zniJTc)

2. Extract the downloaded files if needed

The iOS SDK package contains:

- A `lib/` directory containing the frameworks and bundle
- The required SDK files ready to use

#### Step 2: Locate the Required SDK Files

From the downloaded SharePoint package, you need these 4 files (found in the `lib/` directory):

- `MobileRTC.xcframework` (main framework)
- `MobileRTCScreenShare.xcframework` (screen sharing framework)
- `zoomcml.xcframework` (communication framework)
- `MobileRTCResources.bundle` (resources bundle)

**Note**: These files should be in the `lib/` directory of the downloaded package.

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

> **Quick Checklist**: After completing this step, you should have:
>
> - Framework Search Paths configured
> - MobileRTCResources.bundle in Copy Bundle Resources
> - Three frameworks in Embed Frameworks phase

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

⚠️ **REQUIRED**: The Zoom SDK requires app lifecycle notifications to function properly. Without these methods, your app will crash when attempting to join a meeting.

Update your `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import MobileRTC

@main
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
    super.applicationWillResignActive(application)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    MobileRTC.shared().appDidBecomeActive()
    super.applicationDidBecomeActive(application)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    MobileRTC.shared().appDidEnterBackground()
    super.applicationDidEnterBackground(application)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    MobileRTC.shared().appWillTerminate()
    super.applicationWillTerminate(application)
  }
}
```

> **Note**: The example app in this repo already contains these configurations under `example/ios/`.

> ⚠️ **CRITICAL**: Without these AppDelegate lifecycle methods, the app will crash when attempting to join a meeting. Make sure all four lifecycle methods are implemented and call the corresponding `MobileRTC.shared()` methods.

## Troubleshooting

### iOS Issues

#### App Crashes When Joining Meeting

If your app crashes with an `abort` error when trying to join a meeting, check the following:

1. **AppDelegate Lifecycle Methods** (Most Common Issue):

   - Ensure your `AppDelegate.swift` implements all four lifecycle methods shown above
   - Verify each method calls the corresponding `MobileRTC.shared()` method
   - Make sure you're calling `super` methods as well

2. **Frameworks Not Embedded**:

   - Verify all three frameworks are in the "Embed Frameworks" build phase
   - Check that "Code Sign On Copy" is enabled for all frameworks
   - Ensure frameworks are present in `ios/lib/` directory

3. **Resource Bundle Missing**:

   - Verify `MobileRTCResources.bundle` is in "Copy Bundle Resources" build phase
   - Check that the bundle exists in `ios/lib/` directory

4. **Permissions Missing**:

   - Ensure all three permission keys are in `Info.plist`:
     - `NSCameraUsageDescription`
     - `NSMicrophoneUsageDescription`
     - `NSPhotoLibraryUsageDescription`

5. **Check Xcode Console Logs**:
   - Look for `[ZoomSDK]` prefixed log messages
   - These will help identify where the initialization or join process is failing

#### Build Errors: "Unable to find module dependency: 'MobileRTC'"

- Run `pod install` in the `ios/` directory
- Verify the `post_install` hook in `Podfile` is correctly configured
- Close Xcode completely and reopen `Runner.xcworkspace`
- Clean build folder in Xcode (Product → Clean Build Folder)

#### SDK Initialization Fails (iOS)

- Verify your JWT token is valid and not expired
- Check that the `domain` parameter matches your Zoom account domain
- Ensure `MobileRTCResources.bundle` is correctly added to the app bundle
- Verify the bundle path is correct in Xcode console logs

### Android Issues

#### Build Errors

- **"Could not find mobilertc"**: Ensure you've set up the `mobilertc-repo` directory structure correctly as described in the [Android setup section](#android). Verify the repository paths in your `build.gradle` or `build.gradle.kts`.

- **"Missing permissions"**: Ensure all required permissions are added to your `AndroidManifest.xml` as listed in the [Android permissions section](#required-permissions).

- **Build errors**: Ensure your `minSdkVersion` is at least 28 in `android/app/build.gradle`.

### Common Issues (Both Platforms)

#### SDK Initialization Fails

- Verify your JWT token is valid and not expired
- Check that the `domain` parameter matches your Zoom account domain (defaults to `'zoom.us'`)
- Ensure you're calling `initialize()` before attempting to join a meeting
- Check console logs for detailed error messages

#### Cannot Join Meeting

- **"SDK not initialized"**: Make sure you call `initialize()` and wait for it to complete successfully before attempting to join a meeting
- **"Meeting service not available"**: This usually means initialization hasn't completed yet. Wait for the initialization callback before joining
- **Invalid meeting number**: Check that the meeting number is correct and the meeting exists
- **Meeting password required**: If the meeting has a password, you must provide it in the `joinMeeting()` call

#### Error Codes

When joining a meeting fails, the result will include an error `code`. Common error codes:

- `0`: Success
- `1`: Invalid meeting number
- `2`: Meeting password required
- `3`: Meeting does not exist
- `4`: Network error
- `5`: SDK not initialized

Refer to the [Zoom SDK documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/ios/use-meeting-sdk/start-join-meeting/join-meeting-only) for a complete list of error codes.

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

**Important**: You need to generate a JWT token from your Zoom account credentials:

1. Go to [Zoom App Marketplace](https://marketplace.zoom.us/)
2. Sign in and create a new app or select an existing one
3. Choose **Meeting SDK** as the app type
4. In the app credentials section, generate a JWT token
5. Copy the token and use it in your app

> **Note**: JWT tokens expire. For production apps, consider implementing token refresh logic or using server-side token generation. See the [Zoom SDK documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started) for more details.

### Join a Meeting

After initializing the SDK, you can join a meeting:

```dart
final result = await zoomSdk.joinMeeting(
  meetingNumber: '1234567890',
  password: 'optional_password', // Optional, only needed if meeting requires password
  displayName: 'John Doe',
);

if (result?['status'] == 'success') {
  print('Joining meeting...');
  // The Zoom SDK will automatically present the native meeting UI
  // Your Flutter app will remain in the background during the meeting
} else {
  print('Failed to join: ${result?['code']}');
  print('Error message: ${result?['message']}');
}
```

**Note**: When the join is successful, the Zoom SDK will automatically take over and display the native Zoom meeting interface. Your Flutter app will be in the background while the meeting is active. Users can exit the meeting to return to your Flutter app.

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

**Response format:**

```dart
{
  'status': 'success' | 'failure',
  'code': int,  // 0 for success, error code otherwise
  'message': String?  // Optional error message
}
```

**Note**: The join operation is asynchronous. The result may be returned immediately if there's an error, or via a callback when the meeting is successfully joined. On success, the Zoom SDK will automatically present the native meeting UI.

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.10.0`
- Android: Minimum SDK 28
- iOS: iOS 13.0+

## Important Notes

1. **SDK Files**: The Zoom MobileRTC SDK files are not included in this package due to size and licensing restrictions. You must download and set up the SDK files manually as described in the [Android](#android) and [iOS](#ios) setup sections.

2. **JWT Token**: You need a valid JWT token to initialize the SDK. Generate this from your Zoom developer account:

   - Go to [Zoom App Marketplace](https://marketplace.zoom.us/)
   - Create or select your Meeting SDK app
   - Generate a JWT token in the app credentials section
   - **Important**: JWT tokens expire. You may need to regenerate them periodically or implement token refresh logic

3. **Meeting Requirements**: The meeting must already exist. This plugin does not create meetings, only joins existing ones. You can create meetings using the Zoom API or through the Zoom web interface.

4. **After Joining**: When you successfully join a meeting, the Zoom SDK will automatically present the native Zoom meeting UI. The Flutter app will remain in the background while the meeting is active. The meeting UI is fully managed by the Zoom SDK.

## Running the Example App

To run the example app:

```bash
cd example
fvm flutter pub get
fvm flutter run
```

**Prerequisites:**

- Make sure the `example/android/mobilertc*` folders still exist before running
- For iOS: Ensure the Zoom SDK files are set up in `example/ios/lib/` as described in the [iOS setup section](#ios)
- You'll need a valid JWT token to test initialization and joining meetings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This plugin is provided as-is. Note that the Zoom MobileRTC SDK has its own license terms that you must comply with when using this plugin.

## Related Links

- [Zoom Developer Portal](https://marketplace.zoom.us/)
- [Zoom Meeting SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/introduction)
- [Zoom Android SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android/getting-started)
- [Zoom iOS SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/ios/getting-started)
- [Flutter Documentation](https://flutter.dev/docs)
