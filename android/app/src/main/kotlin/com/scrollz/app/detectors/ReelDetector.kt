package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.security.MessageDigest

data class DetectionResult(
    val isDetected: Boolean,
    val inReelSection: Boolean = false,
    val screenName: String = "Unknown",
    val reelIdentifier: String = "",
    val skipReason: String = ""
)

abstract class ReelDetector {
    abstract val targetPackage: String
    open val screenName: String = "Reels"

    var previousReelIdentifier: String = ""
    private var lastScrollTime: Long = 0

    // Unified processEvent for ALL social apps: Strictly count ONLY physical scroll gestures
    fun processEvent(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): DetectionResult {
        // 1. STRICTLY allow ONLY physical scroll events and window state changes.
        // DO NOT allow TYPE_WINDOW_CONTENT_CHANGED as it fires continuously during video playback.
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_SCROLLED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return DetectionResult(false, skipReason = "Ignored non-scroll event type")
        }

        // 2. Ignore scroll events coming from progress bars / seek bars / sliders
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) {
            val className = event.className?.toString() ?: ""
            if (className.contains("SeekBar", ignoreCase = true) ||
                className.contains("ProgressBar", ignoreCase = true) ||
                className.contains("Slider", ignoreCase = true)) {
                return DetectionResult(false, skipReason = "Ignored scroll from seek/progress bar: $className")
            }
        }

        // 3. Debounce scroll events (500ms window ensures 1 swipe gesture = exactly 1 count)
        val currentTime = System.currentTimeMillis()
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) {
            if (currentTime - lastScrollTime < 500) {
                return DetectionResult(false, skipReason = "Debounced rapid scroll event")
            }
        }

        if (rootNode == null) {
            return DetectionResult(false, skipReason = "Root node is null")
        }

        val rawText = extractRawText(rootNode)
        val textLower = rawText.lowercase()

        // 4. Universal Short-Form Video UI Marker check
        // 4. Robust Short-Form Video UI Marker check
        // We use stricter markers to ensure we are actually in a Reel/Shorts feed and not the Home feed.
        val isReelUi = textLower.contains("remix") || 
                       textLower.contains("original audio") || 
                       textLower.contains("use this sound") ||
                       textLower.contains("soundtrack") ||
                       textLower.contains("spotlight") ||
                       (textLower.contains("shorts") && textLower.contains("dislike")) ||
                       (textLower.contains("reels") && textLower.contains("audio")) ||
                       // If none of the strict markers are found, fallback to checking if it's a full-screen video feed
                       // Usually full screen feeds have very little text compared to Home Feeds.
                       // But the safest fallback is checking for "reels", "shorts" combined with typical actions
                       (textLower.contains("reels") && textLower.contains("comment") && textLower.contains("share") && !textLower.contains("type a message"))

        if (!isReelUi) {
            return DetectionResult(false, inReelSection = false, skipReason = "Doesn't match universal Reel/Shorts UI markers")
        }

        // 5. Extract Unicode-friendly stable text identifier if available
        val currentIdentifier = extractStableIdentifier(rootNode)
        
        // 6. Universal Deduplication Check (FOR ALL EVENT TYPES)
        // If this is the exact same reel identifier, IGNORE IT! (Prevents overcounting while watching)
        if (currentIdentifier.isNotBlank() && currentIdentifier == previousReelIdentifier) {
            return DetectionResult(false, inReelSection = true, reelIdentifier = currentIdentifier, skipReason = "Same Reel Identifier (Already counted)")
        }

        // 7. Confirmed new scroll / reel!
        lastScrollTime = currentTime
        if (currentIdentifier.isNotBlank()) {
            previousReelIdentifier = currentIdentifier
        }

        return DetectionResult(true, inReelSection = true, screenName = this.screenName, reelIdentifier = currentIdentifier, skipReason = "New reel scroll detected")
    }

    open fun reset() {
        previousReelIdentifier = ""
        lastScrollTime = 0
    }

    companion object {
        private val IGNORED_WORDS = setOf(
            "second", "seconds", "sec", "secs", "minute", "minutes", "min", "mins", "hour", "hours", "day", "days", "ago",
            "elapsed", "out", "of", "playing", "paused", "pause", "play", "progress", "bar",
            "seek", "duration", "time", "like", "likes", "liked", "dislike", "dislikes",
            "comment", "comments", "share", "shares", "remix", "audio", "sound", "music",
            "original", "double", "tap", "button", "video", "by", "views", "view", "k", "m",
            "b", "follow", "following", "subscribe", "subscribed", "subscribers", "more",
            "less", "reply", "replies", "shorts", "reels", "spotlight", "feed", "profile",
            "search", "home", "notifications", "menu", "tab", "image", "icon"
        )
    }

    protected fun extractRawText(node: AccessibilityNodeInfo?): String {
        if (node == null) return ""
        val textBuilder = StringBuilder()

        val text = node.text?.toString()?.trim()
        val contentDesc = node.contentDescription?.toString()?.trim()

        if (!text.isNullOrEmpty()) {
            textBuilder.append(text).append(" ")
        }
        if (!contentDesc.isNullOrEmpty()) {
            textBuilder.append(contentDesc).append(" ")
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                textBuilder.append(extractRawText(child))
                child.recycle()
            }
        }
        return textBuilder.toString()
    }

    protected fun extractStableIdentifier(rootNode: AccessibilityNodeInfo?): String {
        val rawText = extractRawText(rootNode)
        if (rawText.isBlank()) return ""

        // Unicode-friendly filtering (Supports English, Hindi, Regional languages, Emojis):
        // Remove numbers [0-9] and ignored words, but keep all letters/symbols in any language!
        val words = rawText.lowercase()
            .replace(Regex("[0-9]"), "") // Strip digits to eliminate ticking timers & view counts
            .split(Regex("\\s+"))
            .filter { word ->
                word.length > 1 && !IGNORED_WORDS.contains(word)
            }

        if (words.isEmpty()) return ""

        val stableContent = words.take(15).joinToString("|")
        return hashString(stableContent)
    }

    protected fun hashString(input: String): String {
        val bytes = MessageDigest.getInstance("MD5").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
