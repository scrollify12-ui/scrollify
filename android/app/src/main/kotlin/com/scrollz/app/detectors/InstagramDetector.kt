package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class InstagramDetector : ReelDetector() {
    override val targetPackage = "com.instagram.android"
    override val screenName = "Instagram Reels"

    override fun isReelViewerActive(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): Boolean {
        if (rootNode == null) return false

        // In Instagram, the reels viewer is often a ViewPager2 or a specific RecyclerView
        // We can check for specific content descriptions that only appear in Reels
        val rawText = extractRawText(rootNode).lowercase()
        
        // Very strong signals for Instagram Reels viewer
        val isReelUi = rawText.contains("reels") && 
                       rawText.contains("audio") && 
                       rawText.contains("like") && 
                       rawText.contains("comment") && 
                       rawText.contains("share") && 
                       !rawText.contains("type a message") // Exclude DMs where people share reels

        return isReelUi
    }
}
