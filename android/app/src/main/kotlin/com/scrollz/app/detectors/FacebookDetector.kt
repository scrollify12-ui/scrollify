package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class FacebookDetector : ReelDetector() {
    override val targetPackage = "com.facebook.katana"
    override val screenName = "Facebook Reels"

    override fun isReelViewerActive(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): Boolean {
        if (rootNode == null) return false

        val rawText = extractRawText(rootNode).lowercase()
        
        val isReelUi = rawText.contains("reels") && 
                       rawText.contains("audio") && 
                       rawText.contains("like") && 
                       rawText.contains("comment") && 
                       rawText.contains("share") &&
                       !rawText.contains("write a comment") // Facebook Home feed has this, Reels usually just say "Comment"
                       
        return isReelUi
    }
}
