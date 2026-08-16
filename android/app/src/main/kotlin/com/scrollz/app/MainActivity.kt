package com.scrollz.app

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.SharedPreferences
import android.util.Log

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.scrollz.app/methods"
    private val EVENT_CHANNEL = "com.scrollz.app/reel_events"
    private lateinit var sharedPrefs: SharedPreferences

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled(context, ReelAccessibilityService::class.java))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var listener: SharedPreferences.OnSharedPreferenceChangeListener? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    listener = SharedPreferences.OnSharedPreferenceChangeListener { prefs, key ->
                        if (key != null && key.startsWith("flutter.reels_")) {
                            val map = mutableMapOf<String, Long>()
                            map["Instagram"] = prefs.getLong("flutter.reels_Instagram", 0L)
                            map["YouTube"] = prefs.getLong("flutter.reels_YouTube", 0L)
                            map["Facebook"] = prefs.getLong("flutter.reels_Facebook", 0L)
                            map["Snapchat"] = prefs.getLong("flutter.reels_Snapchat", 0L)
                            map["Total"] = prefs.getLong("flutter.reels_Total", 0L)
                            map["Daily"] = prefs.getLong("flutter.reelsScrolledToday", 0L)
                            
                            activity.runOnUiThread {
                                events?.success(map)
                            }
                        }
                    }
                    sharedPrefs.registerOnSharedPreferenceChangeListener(listener)
                    
                    // Send initial values
                    val map = mutableMapOf<String, Long>()
                    map["Instagram"] = sharedPrefs.getLong("flutter.reels_Instagram", 0L)
                    map["YouTube"] = sharedPrefs.getLong("flutter.reels_YouTube", 0L)
                    map["Facebook"] = sharedPrefs.getLong("flutter.reels_Facebook", 0L)
                    map["Snapchat"] = sharedPrefs.getLong("flutter.reels_Snapchat", 0L)
                    map["Total"] = sharedPrefs.getLong("flutter.reels_Total", 0L)
                    map["Daily"] = sharedPrefs.getLong("flutter.reelsScrolledToday", 0L)
                    events?.success(map)
                }

                override fun onCancel(arguments: Any?) {
                    if (listener != null) {
                        sharedPrefs.unregisterOnSharedPreferenceChangeListener(listener)
                        listener = null
                    }
                }
            }
        )
    }

    private fun isAccessibilityServiceEnabled(context: Context, accessibilityService: Class<*>): Boolean {
        val expectedComponentName = android.content.ComponentName(context, accessibilityService)
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = android.content.ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }
        return false
    }
}
