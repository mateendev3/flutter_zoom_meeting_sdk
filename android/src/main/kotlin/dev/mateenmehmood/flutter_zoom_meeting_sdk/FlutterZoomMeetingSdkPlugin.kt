package dev.mateenmehmood.flutter_zoom_meeting_sdk

import android.app.Activity
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

private const val TAG = "ZoomMeetingSdkPlugin"
private const val DEFAULT_DOMAIN = "zoom.us"

/** FlutterZoomMeetingSdkPlugin */
class FlutterZoomMeetingSdkPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    ZoomSDKInitializeListener {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingInitResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_zoom_meeting_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pendingInitResult = null
        applicationContext = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "initialize" -> handleInitialize(call, result)
            "joinMeeting" -> handleJoinMeeting(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val context = applicationContext ?: run {
            result.error("missingContext", "Application context is not available yet.", null)
            return
        }

        val token = call.argument<String>("jwtToken") ?: call.argument<String>("token")
        if (token.isNullOrBlank()) {
            result.error("invalidArguments", "A non-empty jwtToken is required to initialize the Zoom SDK.", null)
            return
        }

        val domain = call.argument<String>("domain") ?: DEFAULT_DOMAIN
        val enableLog = call.argument<Boolean>("enableLog") ?: true
        val enableDump = call.argument<Boolean>("enableDump") ?: true
        val logSize = call.argument<Int>("logSize") ?: 5

        val zoomSDK = ZoomSDK.getInstance()
        if (zoomSDK.isInitialized) {
            result.success(mapOf("status" to "already_initialized"))
            return
        }

        if (pendingInitResult != null) {
            result.error("initializeInProgress", "Another initialization is already running.", null)
            return
        }

        val params = ZoomSDKInitParams().apply {
            jwtToken = token
            this.domain = domain
            this.enableLog = enableLog
            enableGenerateDump = enableDump
            this.logSize = logSize
            videoRawDataMemoryMode = ZoomSDKRawDataMemoryMode.ZoomSDKRawDataMemoryModeHeap
        }

        pendingInitResult = result
        zoomSDK.initialize(context, this, params)
    }

    private fun handleJoinMeeting(call: MethodCall, result: Result) {
        val activity = activityBinding?.activity ?: run {
            result.error("missingActivity", "No foreground Activity is available to present the Zoom UI.", null)
            return
        }

        val meetingNumber = call.argument<String>("meetingNumber") ?: call.argument<String>("meetingId")
        if (meetingNumber.isNullOrBlank()) {
            result.error("invalidArguments", "meetingNumber (or meetingId) is required.", null)
            return
        }

        val requestedDisplayName = call.argument<String>("displayName")
            ?: call.argument<String>("userName")
            ?: call.argument<String>("name")
            ?: "Flutter User"
        val password = call.argument<String>("password") ?: ""

        val zoomSDK = ZoomSDK.getInstance()
        if (!zoomSDK.isInitialized) {
            result.error("notInitialized", "Initialize the Zoom SDK before attempting to join a meeting.", null)
            return
        }

        val meetingService = zoomSDK.meetingService ?: run {
            result.error("serviceUnavailable", "Meeting service is not ready.", null)
            return
        }

        val params = JoinMeetingParams().apply {
            meetingNo = meetingNumber.trim()
            displayName = requestedDisplayName.trim()
            this.password = password
        }
        val options = JoinMeetingOptions()

        val joinResult = meetingService.joinMeetingWithParams(activity, params, options)
        val status = if (joinResult == MeetingError.MEETING_ERROR_SUCCESS) {
            "success"
        } else {
            "failure"
        }
        result.success(
            mapOf(
                "status" to status,
                "code" to joinResult
            )
        )
    }

    override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
        val initResult = pendingInitResult ?: return
        pendingInitResult = null
        if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
            initResult.success(mapOf("status" to "success"))
        } else {
            initResult.error(
                "initializeFailed",
                "Failed to initialize Zoom SDK. errorCode=$errorCode, internalErrorCode=$internalErrorCode",
                mapOf(
                    "errorCode" to errorCode,
                    "internalErrorCode" to internalErrorCode
                )
            )
        }
    }

    override fun onZoomAuthIdentityExpired() {
        Log.d(TAG, "Zoom authentication identity expired.")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }
}
