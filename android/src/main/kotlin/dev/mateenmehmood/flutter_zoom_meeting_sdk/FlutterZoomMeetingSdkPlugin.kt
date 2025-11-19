/**
 * Flutter plugin implementation for Zoom MobileRTC SDK on Android.
 *
 * This plugin provides a bridge between Flutter and the Zoom MobileRTC SDK, enabling Flutter
 * applications to initialize the Zoom SDK and join meetings on Android devices.
 *
 * The plugin handles:
 * - SDK initialization with JWT token authentication
 * - Joining Zoom meetings with meeting number and optional password
 * - Activity lifecycle management for presenting Zoom UI
 * - Error handling and logging
 */
package dev.mateenmehmood.flutter_zoom_meeting_sdk

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import us.zoom.sdk.JoinMeetingOptions
import us.zoom.sdk.JoinMeetingParams
import us.zoom.sdk.MeetingError
import us.zoom.sdk.ZoomError
import us.zoom.sdk.ZoomSDK
import us.zoom.sdk.ZoomSDKInitParams
import us.zoom.sdk.ZoomSDKInitializeListener
import us.zoom.sdk.ZoomSDKRawDataMemoryMode

/** Log tag for this plugin */
private const val TAG = "ZoomMeetingSdkPlugin"

/** Default Zoom domain if not specified */
private const val DEFAULT_DOMAIN = "zoom.us"

/**
 * Flutter plugin for Zoom MobileRTC SDK on Android.
 *
 * This class implements the Flutter plugin interface and handles communication between Flutter and
 * the native Zoom SDK. It manages SDK initialization, meeting joining, and activity lifecycle.
 *
 * @see FlutterPlugin
 * @see MethodCallHandler
 * @see ActivityAware
 * @see ZoomSDKInitializeListener
 */
class FlutterZoomMeetingSdkPlugin :
        FlutterPlugin, MethodCallHandler, ActivityAware, ZoomSDKInitializeListener {

    /** Method channel for Flutter-to-native communication */
    private lateinit var channel: MethodChannel

    /** Application context for SDK initialization */
    private var applicationContext: Context? = null

    /** Activity binding for presenting Zoom UI */
    private var activityBinding: ActivityPluginBinding? = null

    /** Pending initialization result callback (stored during async initialization) */
    private var pendingInitResult: Result? = null

    /**
     * Called when the plugin is attached to the Flutter engine.
     *
     * Sets up the method channel and stores the application context.
     *
     * @param flutterPluginBinding The Flutter plugin binding containing engine references
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_zoom_meeting_sdk")
        channel.setMethodCallHandler(this)
        Log.d(TAG, "Plugin attached to engine")
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     *
     * Cleans up resources and removes the method call handler.
     *
     * @param binding The Flutter plugin binding
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pendingInitResult = null
        applicationContext = null
        Log.d(TAG, "Plugin detached from engine")
    }

    /**
     * Handles method calls from Flutter.
     *
     * Routes method calls to the appropriate handler based on the method name.
     *
     * @param call The method call from Flutter
     * @param result The result callback to send response back to Flutter
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "joinMeeting" -> handleJoinMeeting(call, result)
            else -> {
                Log.w(TAG, "Unknown method called: ${call.method}")
                result.notImplemented()
            }
        }
    }

    /**
     * Handles the initialize method call from Flutter.
     *
     * Initializes the Zoom MobileRTC SDK with the provided JWT token and configuration. The
     * initialization is asynchronous, and the result is returned via the callback in
     * [onZoomSDKInitializeResult].
     *
     * @param call The method call containing initialization parameters:
     * - jwtToken (required): JWT token for authentication
     * - domain (optional): Zoom domain, defaults to "zoom.us"
     * - enableLog (optional): Enable SDK logging, defaults to true
     * - enableDump (optional): Enable crash dump generation, defaults to true
     * - logSize (optional): Maximum log file size in MB, defaults to 5
     * @param result The result callback to send response back to Flutter
     */
    private fun handleInitialize(call: MethodCall, result: Result) {
        Log.d(TAG, "Initialize method called")

        // Validate application context is available
        val context =
                applicationContext
                        ?: run {
                            Log.e(TAG, "Initialize failed: Application context not available")
                            result.error(
                                    "missingContext",
                                    "Application context is not available yet.",
                                    null
                            )
                            return
                        }

        // Extract JWT token (supports both "jwtToken" and "token" parameter names)
        val token = call.argument<String>("jwtToken") ?: call.argument<String>("token")
        if (token.isNullOrBlank()) {
            Log.e(TAG, "Initialize failed: JWT token is missing or empty")
            result.error(
                    "invalidArguments",
                    "A non-empty jwtToken is required to initialize the Zoom SDK.",
                    null
            )
            return
        }

        // Extract optional parameters with defaults
        val domain = call.argument<String>("domain") ?: DEFAULT_DOMAIN
        val enableLog = call.argument<Boolean>("enableLog") ?: true
        val enableDump = call.argument<Boolean>("enableDump") ?: true
        val logSize = call.argument<Int>("logSize") ?: 5

        val zoomSDK = ZoomSDK.getInstance()

        // Check if SDK is already initialized
        if (zoomSDK.isInitialized) {
            Log.d(TAG, "Zoom SDK already initialized")
            result.success(mapOf("status" to "already_initialized"))
            return
        }

        // Prevent concurrent initialization attempts
        if (pendingInitResult != null) {
            Log.w(TAG, "Initialize failed: Another initialization is already in progress")
            result.error("initializeInProgress", "Another initialization is already running.", null)
            return
        }

        Log.d(TAG, "Starting Zoom SDK initialization (domain: $domain, logSize: ${logSize}MB)")

        // Configure initialization parameters
        val params =
                ZoomSDKInitParams().apply {
                    jwtToken = token
                    this.domain = domain
                    this.enableLog = enableLog
                    enableGenerateDump = enableDump
                    this.logSize = logSize
                    // Use heap memory mode for video raw data
                    videoRawDataMemoryMode = ZoomSDKRawDataMemoryMode.ZoomSDKRawDataMemoryModeHeap
                }

        // Store result callback for async initialization response
        pendingInitResult = result
        // Start asynchronous SDK initialization
        zoomSDK.initialize(context, this, params)
    }

    /**
     * Handles the joinMeeting method call from Flutter.
     *
     * Joins a Zoom meeting with the specified meeting number, display name, and optional password.
     * The meeting UI is presented using the current Activity.
     *
     * @param call The method call containing meeting parameters:
     * - meetingNumber or meetingId (required): The Zoom meeting number
     * - displayName, userName, or name (optional): Display name, defaults to "Flutter User"
     * - password (optional): Meeting password if required
     * @param result The result callback to send response back to Flutter
     */
    private fun handleJoinMeeting(call: MethodCall, result: Result) {
        // Validate Activity is available (required to present Zoom UI)
        val activity =
                activityBinding?.activity
                        ?: run {
                            Log.e(TAG, "Join meeting failed: No foreground Activity available")
                            result.error(
                                    "missingActivity",
                                    "No foreground Activity is available to present the Zoom UI.",
                                    null
                            )
                            return
                        }

        // Extract meeting number (supports both "meetingNumber" and "meetingId" parameter names)
        val meetingNumber =
                call.argument<String>("meetingNumber") ?: call.argument<String>("meetingId")
        if (meetingNumber.isNullOrBlank()) {
            Log.e(TAG, "Join meeting failed: Meeting number is missing")
            result.error("invalidArguments", "meetingNumber (or meetingId) is required.", null)
            return
        }

        // Extract display name (supports multiple parameter names with fallback)
        val requestedDisplayName =
                call.argument<String>("displayName")
                        ?: call.argument<String>("userName") ?: call.argument<String>("name")
                                ?: "Flutter User"
        val password = call.argument<String>("password") ?: ""

        val zoomSDK = ZoomSDK.getInstance()

        // Ensure SDK is initialized before joining
        if (!zoomSDK.isInitialized) {
            Log.e(TAG, "Join meeting failed: Zoom SDK not initialized")
            result.error(
                    "notInitialized",
                    "Initialize the Zoom SDK before attempting to join a meeting.",
                    null
            )
            return
        }

        // Get meeting service (required to join meetings)
        val meetingService =
                zoomSDK.meetingService
                        ?: run {
                            Log.e(TAG, "Join meeting failed: Meeting service not available")
                            result.error(
                                    "serviceUnavailable",
                                    "Meeting service is not ready.",
                                    null
                            )
                            return
                        }

        Log.d(TAG, "Joining meeting: $meetingNumber (displayName: $requestedDisplayName)")

        // Configure meeting join parameters
        val params =
                JoinMeetingParams().apply {
                    meetingNo = meetingNumber.trim()
                    displayName = requestedDisplayName.trim()
                    this.password = password
                }
        val options = JoinMeetingOptions()

        // Attempt to join the meeting
        val joinResult = meetingService.joinMeetingWithParams(activity, params, options)
        val status =
                if (joinResult == MeetingError.MEETING_ERROR_SUCCESS) {
                    Log.d(TAG, "Join meeting request accepted (code: $joinResult)")
                    "success"
                } else {
                    Log.w(TAG, "Join meeting request failed (code: $joinResult)")
                    "failure"
                }
        result.success(mapOf("status" to status, "code" to joinResult))
    }

    /**
     * Callback invoked when Zoom SDK initialization completes.
     *
     * This is called asynchronously after [handleInitialize] starts the initialization process. The
     * result is sent back to Flutter via the stored [pendingInitResult] callback.
     *
     * @param errorCode The error code from Zoom SDK (0 for success)
     * @param internalErrorCode Internal error code for additional debugging information
     */
    override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
        val initResult = pendingInitResult ?: return
        pendingInitResult = null

        if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
            Log.d(TAG, "Zoom SDK initialized successfully")
            initResult.success(mapOf("status" to "success"))
        } else {
            Log.e(
                    TAG,
                    "Zoom SDK initialization failed: errorCode=$errorCode, internalErrorCode=$internalErrorCode"
            )
            initResult.error(
                    "initializeFailed",
                    "Failed to initialize Zoom SDK. errorCode=$errorCode, internalErrorCode=$internalErrorCode",
                    mapOf("errorCode" to errorCode, "internalErrorCode" to internalErrorCode)
            )
        }
    }

    /**
     * Callback invoked when Zoom authentication identity expires.
     *
     * This occurs when the JWT token used for initialization expires. The SDK may need to be
     * re-initialized with a new token.
     */
    override fun onZoomAuthIdentityExpired() {
        Log.w(TAG, "Zoom authentication identity expired")
    }

    /**
     * Called when the plugin is attached to an Activity.
     *
     * Stores the activity binding which is required to present the Zoom meeting UI.
     *
     * @param binding The activity plugin binding
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        Log.d(TAG, "Activity attached")
    }

    /**
     * Called when the Activity is detached due to configuration changes.
     *
     * Clears the activity binding temporarily. The Activity will be reattached via
     * [onReattachedToActivityForConfigChanges].
     */
    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    /**
     * Called when the Activity is reattached after configuration changes.
     *
     * Restores the activity binding after a configuration change (e.g., screen rotation).
     *
     * @param binding The activity plugin binding
     */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    /**
     * Called when the plugin is detached from the Activity.
     *
     * Clears the activity binding when the Activity is destroyed or the plugin is removed.
     */
    override fun onDetachedFromActivity() {
        activityBinding = null
        Log.d(TAG, "Activity detached")
    }
}
