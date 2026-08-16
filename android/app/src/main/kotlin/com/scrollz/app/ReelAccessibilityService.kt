package com.scrollz.app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import com.scrollz.app.detectors.*

class ReelAccessibilityService : AccessibilityService() {

    private val detectors = mapOf(
        "com.instagram.android" to InstagramDetector(),
        "com.google.android.youtube" to YoutubeDetector(),
        "com.facebook.katana" to FacebookDetector(),
        "com.snapchat.android" to SnapchatDetector()
    )
    
    private var currentPackage = ""
    private lateinit var sharedPrefs: SharedPreferences

    private var overlayView: View? = null
    private var overlayTextView: TextView? = null
    private var isOverlayShowing = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("ReelService", "Service Connected")
        sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        val packageName = event.packageName?.toString() ?: return
        
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            if (packageName != currentPackage) {
                detectors[currentPackage]?.reset()
                currentPackage = packageName
            }
        }
        
        val detector = detectors[packageName] ?: return
        
        val rootNode = try { rootInActiveWindow } catch (e: Exception) { null }
        
        val previousId = detector.previousReelIdentifier
        val result = detector.processEvent(event, rootNode)
        
        // Log ONLY on TYPE_VIEW_SCROLLED or TYPE_WINDOW_STATE_CHANGED
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED || 
            event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            
            val appKey = getAppKey(packageName)
            val prefKey = "flutter.reels_$appKey"
            
            if (result.inReelSection) {
                if (result.isDetected) {
                    incrementReelCount(packageName)
                }
                
                val currentCount = sharedPrefs.getLong(prefKey, 0L)
                showOverlay()
                updateOverlayText(currentCount.toString())
            } else {
                hideOverlay()
            }
            
            val counterAfter = sharedPrefs.getLong(prefKey, 0L)

            // Print exact requested debug log format
            Log.d("ReelService", """
                |==============================================
                |Package: $packageName
                |In Reel Section: ${result.inReelSection}
                |Current Reel Identifier: ${result.reelIdentifier}
                |Previous Reel Identifier: $previousId
                |New Reel Detected: ${if (result.isDetected) "YES" else "NO"}
                |Reason: ${if (result.isDetected) "New Unique Reel Content" else result.skipReason}
                |Counter: $counterAfter
                |==============================================
            """.trimMargin())
        }
    }
    
    private fun getAppKey(packageName: String): String {
        return when(packageName) {
            "com.instagram.android" -> "Instagram"
            "com.google.android.youtube" -> "YouTube"
            "com.facebook.katana" -> "Facebook"
            "com.snapchat.android" -> "Snapchat"
            else -> "Other"
        }
    }

    private fun incrementReelCount(packageName: String) {
        val appKey = getAppKey(packageName)
        
        val prefKey = "flutter.reels_$appKey"
        val currentCount = sharedPrefs.getLong(prefKey, 0L)
        sharedPrefs.edit().putLong(prefKey, currentCount + 1).apply()
        
        val totalKey = "flutter.reels_Total"
        val totalCount = sharedPrefs.getLong(totalKey, 0L)
        sharedPrefs.edit().putLong(totalKey, totalCount + 1).apply()
        
        val dailyKey = "flutter.reelsScrolledToday"
        val dailyCount = sharedPrefs.getLong(dailyKey, 0L)
        sharedPrefs.edit().putLong(dailyKey, dailyCount + 1).apply()
    }

    override fun onInterrupt() {
        Log.d("ReelService", "Service Interrupted")
        hideOverlay()
    }

    override fun onDestroy() {
        super.onDestroy()
        hideOverlay()
    }

    private fun initOverlay() {
        if (overlayView == null) {
            val frameLayout = FrameLayout(this)
            val bg = GradientDrawable()
            bg.setColor(Color.parseColor("#FFD700")) // Gold background
            bg.cornerRadius = 50f
            frameLayout.background = bg
            frameLayout.setPadding(48, 12, 48, 12)
            
            val tv = TextView(this)
            tv.setTextColor(Color.BLACK)
            tv.textSize = 14f
            tv.typeface = Typeface.DEFAULT_BOLD
            tv.text = "0"
            tv.gravity = Gravity.CENTER
            
            val tvParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            tvParams.gravity = Gravity.CENTER
            frameLayout.addView(tv, tvParams)
            
            overlayView = frameLayout
            overlayTextView = tv
        }
    }

    private fun showOverlay() {
        if (!isOverlayShowing) {
            initOverlay()
            val wm = getSystemService(WINDOW_SERVICE) as WindowManager
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            params.y = 120 // Offset from top notch/status bar

            try {
                wm.addView(overlayView, params)
                isOverlayShowing = true
            } catch (e: Exception) {
                Log.e("ReelService", "Failed to add overlay", e)
            }
        }
    }

    private fun hideOverlay() {
        if (isOverlayShowing && overlayView != null) {
            val wm = getSystemService(WINDOW_SERVICE) as WindowManager
            try {
                wm.removeView(overlayView)
                isOverlayShowing = false
            } catch (e: Exception) {
                Log.e("ReelService", "Failed to remove overlay", e)
            }
        }
    }

    private fun updateOverlayText(text: String) {
        overlayTextView?.text = text
    }
}
