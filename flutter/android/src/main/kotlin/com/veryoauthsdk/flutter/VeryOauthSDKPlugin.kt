package com.veryoauthsdk.flutter

import android.content.Context
import com.veryoauthsdk.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VeryOauthSDKPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: android.app.Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "very_oauth_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "authenticate" -> {
                authenticate(call, result)
            }
            "cancelAuthentication" -> {
                cancelAuthentication(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun authenticate(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any> ?: return result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
        
        val clientId = args["clientId"] as? String ?: return result.error("INVALID_ARGUMENTS", "clientId is required", null)
        val redirectUri = args["redirectUri"] as? String ?: return result.error("INVALID_ARGUMENTS", "redirectUri is required", null)
        val userId = args["userId"] as? String
        val authorizationUrl = args["authorizationUrl"] as? String
        val scope = args["scope"] as? String
        val browserModeIndex = args["browserMode"] as? Int ?: 1 // Default to webview
        val language = args["language"] as? String

        val browserMode = when (browserModeIndex) {
            0 -> BrowserMode.SYSTEM_BROWSER
            1 -> BrowserMode.WEBVIEW
            else -> BrowserMode.WEBVIEW
        }

        val config = OAuthConfig(
            clientId = clientId,
            redirectUri = redirectUri,
            userId = userId,
            authorizationUrl = authorizationUrl ?: "https://connect.very.org/oauth/authorize",
            scope = scope,
            browserMode = browserMode,
            language = language
        )

        val activity = this.activity ?: return result.error("NO_ACTIVITY", "No activity available", null)

        VeryOauthSDK.getInstance().authenticate(
            context = activity,
            config = config,
            callback = { oauthResult ->
                val resultMap = mapOf(
                    "code" to oauthResult.code,
                    "error" to oauthResult.error.ordinal
                )
                result.success(resultMap)
            }
        )
    }

    private fun cancelAuthentication(result: Result) {
        VeryOauthSDK.getInstance().cancelAuthentication()
        result.success(null)
    }
}
