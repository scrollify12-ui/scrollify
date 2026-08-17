package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class SnapchatDetector : ReelDetector() {
    override val targetPackage = "com.snapchat.android"
    override val screenName = "Snapchat Spotlight"

    override fun isReelViewerActive(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): Boolean {
        if (rootNode == null) return false

        val rawText = extractRawText(rootNode).lowercase()
        
        val isSpotlightUi = rawText.contains("spotlight") && 
                            rawText.contains("like") && 
                            rawText.contains("send to")
                            
        return isSpotlightUi
    }
}
