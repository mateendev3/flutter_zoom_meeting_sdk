import Flutter
import UIKit
import MobileRTC

/// Flutter plugin implementation for Zoom MobileRTC SDK on iOS.
///
/// This plugin provides a bridge between Flutter and the Zoom MobileRTC SDK, enabling Flutter
/// applications to initialize the Zoom SDK and join meetings on iOS devices.
///
/// The plugin handles:
/// - SDK initialization with JWT token authentication
/// - Joining Zoom meetings with meeting number and optional password
/// - Error handling and logging
public class FlutterZoomMeetingSdkPlugin: NSObject, FlutterPlugin, MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate {
    
    /// Method channel for Flutter-to-native communication
    private var channel: FlutterMethodChannel?
    
    /// Pending initialization result callback (stored during async initialization)
    private var pendingInitResult: FlutterResult?
    
    /// Pending join meeting result callback (stored during async join)
    private var pendingJoinResult: FlutterResult?
    
    /// Default Zoom domain if not specified
    private let defaultDomain = "zoom.us"
    
    /// Called when the plugin is registered with Flutter
    public static func register(with registrar: FlutterPluginRegistrar) {
        NSLog("[ZoomSDK] Plugin registering with Flutter")
        
        let channel = FlutterMethodChannel(name: "flutter_zoom_meeting_sdk", binaryMessenger: registrar.messenger())
        let instance = FlutterZoomMeetingSdkPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        NSLog("[ZoomSDK] Plugin registered successfully")
    }

    /// Handles method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("[ZoomSDK] Method called: \(call.method)")
        switch call.method {
        case "initialize":
            handleInitialize(call: call, result: result)
        case "joinMeeting":
            handleJoinMeeting(call: call, result: result)
        default:
            NSLog("[ZoomSDK] Unknown method: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Handles the initialize method call from Flutter
    ///
    /// Initializes the Zoom MobileRTC SDK with the provided JWT token and configuration.
    /// The initialization is asynchronous, and the result is returned via the callback in
    /// `onMobileRTCAuthReturn`.
    ///
    /// Parameters:
    /// - jwtToken (required): JWT token for authentication
    /// - domain (optional): Zoom domain, defaults to "zoom.us"
    /// - enableLog (optional): Enable SDK logging, defaults to true
    /// - enableDump (optional): Enable crash dump generation, defaults to true
    /// - logSize (optional): Maximum log file size in MB, defaults to 5
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("[ZoomSDK] handleInitialize called")
        guard let args = call.arguments as? [String: Any] else {
            NSLog("[ZoomSDK] ERROR: Invalid arguments provided")
            result(FlutterError(
                code: "invalidArguments",
                message: "Invalid arguments provided",
                details: nil
            ))
            return
        }
        
        // Extract JWT token
        guard let jwtToken = args["jwtToken"] as? String, !jwtToken.isEmpty else {
            NSLog("[ZoomSDK] ERROR: JWT token is missing or empty")
            result(FlutterError(
                code: "invalidArguments",
                message: "A non-empty jwtToken is required to initialize the Zoom SDK.",
                details: nil
            ))
            return
        }
        
        // Extract optional parameters with defaults
        let domain = args["domain"] as? String ?? defaultDomain
        let enableLog = args["enableLog"] as? Bool ?? true
        let enableDump = args["enableDump"] as? Bool ?? true
        let logSize = args["logSize"] as? Int ?? 5
        
        NSLog("[ZoomSDK] Initialization params - domain: \(domain), enableLog: \(enableLog), logSize: \(logSize)MB")
        
        let mobileRTC = MobileRTC.shared()
        
        // Check if SDK is already initialized
        if mobileRTC.isRTCAuthorized() {
            NSLog("[ZoomSDK] SDK already initialized")
            result(["status": "already_initialized"])
            return
        }
        
        // Prevent concurrent initialization attempts
        if pendingInitResult != nil {
            NSLog("[ZoomSDK] ERROR: Another initialization is already in progress")
            result(FlutterError(
                code: "initializeInProgress",
                message: "Another initialization is already running.",
                details: nil
            ))
            return
        }
        
        // Configure initialization parameters
        let initContext = MobileRTCSDKInitContext()
        initContext.domain = domain
        initContext.enableLog = enableLog
        initContext.locale = MobileRTC_ZoomLocale(rawValue: 0)!
        
        // Verify MobileRTCResources.bundle is available in the main bundle
        // Users must add this bundle to their Xcode project manually
        NSLog("[ZoomSDK] Checking for MobileRTCResources.bundle in main bundle...")
        guard let bundlePath = Bundle.main.path(forResource: "MobileRTCResources", ofType: "bundle") else {
            NSLog("[ZoomSDK] ERROR: MobileRTCResources.bundle not found in app bundle")
            result(FlutterError(
                code: "missingResourceBundle",
                message: "MobileRTCResources.bundle not found. Please add the Zoom SDK bundle to your Xcode project. See README.md for setup instructions.",
                details: nil
            ))
            return
        }
        
        NSLog("[ZoomSDK] Found MobileRTCResources.bundle at: \(bundlePath)")
        initContext.bundleResPath = bundlePath
        
        // Initialize the SDK
        NSLog("[ZoomSDK] Calling MobileRTC.initialize()...")
        let initSuccess = mobileRTC.initialize(initContext)
        
        if !initSuccess {
            NSLog("[ZoomSDK] ERROR: MobileRTC.initialize() returned false")
            result(FlutterError(
                code: "initializeFailed",
                message: "Failed to initialize Zoom SDK.",
                details: nil
            ))
            return
        }
        
        NSLog("[ZoomSDK] SDK initialization call succeeded, getting auth service...")
        
        // Get auth service and set JWT token
        guard let authService = mobileRTC.getAuthService() else {
            NSLog("[ZoomSDK] ERROR: Auth service is not available")
            result(FlutterError(
                code: "serviceUnavailable",
                message: "Auth service is not available.",
                details: nil
            ))
            return
        }
        
        NSLog("[ZoomSDK] Auth service obtained, setting delegate and JWT token...")
        
        // Store result callback for async authentication response
        pendingInitResult = result
        
        // Set delegate and JWT token, then authenticate
        authService.delegate = self
        authService.jwtToken = jwtToken
        NSLog("[ZoomSDK] Calling sdkAuth()...")
        authService.sdkAuth()
    }
    
    /// Handles the joinMeeting method call from Flutter
    ///
    /// Joins a Zoom meeting with the specified meeting number, display name, and optional password.
    ///
    /// Parameters:
    /// - meetingNumber or meetingId (required): The Zoom meeting number
    /// - displayName, userName, or name (required): Display name
    /// - password (optional): Meeting password if required
    private func handleJoinMeeting(call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("[ZoomSDK] handleJoinMeeting called")
        guard let args = call.arguments as? [String: Any] else {
            NSLog("[ZoomSDK] ERROR: Invalid arguments for joinMeeting")
            result(FlutterError(
                code: "invalidArguments",
                message: "Invalid arguments provided",
                details: nil
            ))
            return
        }
        
        // Extract meeting number (supports both "meetingNumber" and "meetingId")
        let meetingNumber = (args["meetingNumber"] as? String) ?? (args["meetingId"] as? String)
        guard let meetingNumber = meetingNumber, !meetingNumber.isEmpty else {
            NSLog("[ZoomSDK] ERROR: Meeting number is missing")
            result(FlutterError(
                code: "invalidArguments",
                message: "meetingNumber (or meetingId) is required.",
                details: nil
            ))
            return
        }
        
        // Extract display name (supports multiple parameter names with fallback)
        let displayName = (args["displayName"] as? String) ??
                         (args["userName"] as? String) ??
                         (args["name"] as? String) ??
                         "Flutter User"
        
        let password = args["password"] as? String ?? ""
        
        NSLog("[ZoomSDK] Join meeting params - meetingNumber: \(meetingNumber), displayName: \(displayName), hasPassword: \(!password.isEmpty)")
        
        let mobileRTC = MobileRTC.shared()
        
        // Ensure SDK is initialized before joining
        guard mobileRTC.isRTCAuthorized() else {
            NSLog("[ZoomSDK] ERROR: SDK not initialized")
            result(FlutterError(
                code: "notInitialized",
                message: "Initialize the Zoom SDK before attempting to join a meeting.",
                details: nil
            ))
            return
        }
        
        // Get meeting service (required to join meetings)
        guard let meetingService = mobileRTC.getMeetingService() else {
            NSLog("[ZoomSDK] ERROR: Meeting service not available")
            result(FlutterError(
                code: "serviceUnavailable",
                message: "Meeting service is not ready.",
                details: nil
            ))
            return
        }
        
        NSLog("[ZoomSDK] Meeting service obtained, setting delegate...")
        
        // Set delegate for meeting events
        meetingService.delegate = self
        
        // Store result callback for async join response
        pendingJoinResult = result
        
        // Configure meeting join parameters
        let joinParam = MobileRTCMeetingJoinParam()
        joinParam.meetingNumber = meetingNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        joinParam.userName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        joinParam.password = password
        
        // Attempt to join the meeting
        NSLog("[ZoomSDK] Calling joinMeeting()...")
        let joinResult = meetingService.joinMeeting(with: joinParam)
        
        // If joinMeeting returns an error immediately, return it
        // Otherwise, wait for delegate callbacks (onJoinMeetingConfirmed or onMeetingError)
        if joinResult.rawValue != 0 {
            NSLog("[ZoomSDK] joinMeeting() returned error code: \(joinResult.rawValue)")
            pendingJoinResult = nil
            result([
                "status": "failure",
                "code": joinResult.rawValue
            ])
        } else {
            NSLog("[ZoomSDK] joinMeeting() call succeeded, waiting for delegate callbacks...")
        }
        // If successful, the result will be sent via delegate callbacks
    }
    
    // MARK: - MobileRTCAuthDelegate
    
    /// Callback invoked when Zoom SDK authentication completes
    ///
    /// This is called asynchronously after `handleInitialize` starts the authentication process.
    /// The result is sent back to Flutter via the stored `pendingInitResult` callback.
    public func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        NSLog("[ZoomSDK] onMobileRTCAuthReturn called with error code: \(returnValue.rawValue)")
        guard let initResult = pendingInitResult else {
            NSLog("[ZoomSDK] WARNING: onMobileRTCAuthReturn called but no pending result")
            return
        }
        pendingInitResult = nil
        
        if returnValue.rawValue == 0 {
            NSLog("[ZoomSDK] Authentication successful!")
            
            // Enable auto register notification service for push notifications
            if let authService = MobileRTC.shared().getAuthService() {
                authService.enableAutoRegisterNotificationService(forLogin: true)
                NSLog("[ZoomSDK] Enabled auto register notification service")
            }
            
            initResult(["status": "success"])
        } else {
            NSLog("[ZoomSDK] Authentication failed with error code: \(returnValue.rawValue)")
            initResult(FlutterError(
                code: "initializeFailed",
                message: "Failed to initialize Zoom SDK. Error code: \(returnValue.rawValue)",
                details: ["errorCode": returnValue.rawValue]
            ))
        }
    }
    
    /// Callback invoked when Zoom authentication identity expires
    ///
    /// This occurs when the JWT token used for initialization expires.
    /// The SDK may need to be re-initialized with a new token.
    public func onMobileRTCAuthExpired() {
        NSLog("[ZoomSDK] Authentication expired")
        // Notify Flutter about token expiration
        channel?.invokeMethod("onAuthExpired", arguments: nil)
    }
    
    // MARK: - MobileRTCMeetingServiceDelegate
    
    /// Callback invoked when a meeting error occurs
    public func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        NSLog("[ZoomSDK] onMeetingError called - error code: \(error.rawValue), message: \(message ?? "nil")")
        guard let joinResult = pendingJoinResult else {
            NSLog("[ZoomSDK] WARNING: onMeetingError called but no pending result")
            return
        }
        pendingJoinResult = nil
        
        joinResult([
            "status": "failure",
            "code": error.rawValue,
            "message": message ?? ""
        ])
    }
    
    /// Callback invoked when meeting state changes
    public func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        NSLog("[ZoomSDK] onMeetingStateChange called - state: \(state.rawValue)")
        // Meeting state changes are logged for debugging
        // Successful join is confirmed via onJoinMeetingConfirmed callback
    }
    
    /// Callback invoked when the meeting has been joined successfully
    public func onJoinMeetingConfirmed() {
        NSLog("[ZoomSDK] onJoinMeetingConfirmed called - meeting joined successfully!")
        guard let joinResult = pendingJoinResult else {
            NSLog("[ZoomSDK] WARNING: onJoinMeetingConfirmed called but no pending result")
            return
        }
        pendingJoinResult = nil
        
        joinResult([
            "status": "success",
            "code": 0
        ])
  }
    
}
