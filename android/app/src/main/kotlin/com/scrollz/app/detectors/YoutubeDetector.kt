package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class YoutubeDetector : ReelDetector() {
    override val targetPackage = "com.google.android.youtube"
    override val screenName = "YouTube Shorts"

    override fun isReelViewerActive(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): Boolean {
        if (rootNode == null) return false

        val rawText = extractRawText(rootNode).lowercase()
        
        // YouTube Shorts usually has specific buttons like Dislike, Remix, Use this sound
        val isShortsUi = (rawText.contains("shorts") && rawText.contains("dislike") && rawText.contains("share")) ||
                         (rawText.contains("use this sound") && rawText.contains("dislike"))
                         
        return isShortsUi
    }
}
