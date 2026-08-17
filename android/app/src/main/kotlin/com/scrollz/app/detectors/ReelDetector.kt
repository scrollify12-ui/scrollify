package com.scrollz.app.detectors

import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import java.security.MessageDigest

enum class ViewerState {
    UNKNOWN,
    ENTERED_VIEWER,
    SCROLLED_NEW_CONTENT,
    DUPLICATE_CONTENT,
    EXITED_VIEWER
}

data class DetectionResult(
    val state: ViewerState,
    val screenName: String = "Unknown",
    val reelIdentifier: String = "",
    val skipReason: String = ""
)

abstract class ReelDetector {
    abstract val targetPackage: String
    open val screenName: String = "Reels"

    var previousReelIdentifier: String = ""
    private var lastScrollTime: Long = 0

    // To be implemented by specific apps to check for specific UI IDs or view hierarchies
    abstract fun isReelViewerActive(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): Boolean

    // Optional override for custom text/ID based identifiers
    open fun extractContentIdentifier(rootNode: AccessibilityNodeInfo?): String {
        return extractStableIdentifier(rootNode)
    }

    fun processEvent(event: AccessibilityEvent, rootNode: AccessibilityNodeInfo?): DetectionResult {
        // We evaluate window state changes and scrolls
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_SCROLLED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return DetectionResult(ViewerState.UNKNOWN, skipReason = "Ignored non-scroll/window event")
        }

        // 1. Determine if we are inside the Reel/Short viewer
        val inViewer = isReelViewerActive(event, rootNode)
        if (!inViewer) {
            // If we get a window state change that says we're NOT in a viewer, we exit.
            if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                return DetectionResult(ViewerState.EXITED_VIEWER, skipReason = "Navigated away from viewer")
            }
            return DetectionResult(ViewerState.UNKNOWN, skipReason = "Not in viewer")
        }

        // We are confirmed to be in the viewer!
        // Ignore seek bar scrolls
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) {
            val className = event.className?.toString() ?: ""
            if (className.contains("SeekBar", ignoreCase = true) ||
                className.contains("ProgressBar", ignoreCase = true) ||
                className.contains("Slider", ignoreCase = true)) {
                return DetectionResult(ViewerState.ENTERED_VIEWER, skipReason = "In viewer, ignored seekbar scroll")
            }
        }

        // Debounce rapid physical scrolls
        val currentTime = System.currentTimeMillis()
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) {
            if (currentTime - lastScrollTime < 500) {
                return DetectionResult(ViewerState.ENTERED_VIEWER, skipReason = "Debounced rapid scroll")
            }
        }

        // 2. Extract Identifier for Deduplication
        val currentIdentifier = extractContentIdentifier(rootNode)
        
        if (currentIdentifier.isNotBlank() && currentIdentifier == previousReelIdentifier) {
            return DetectionResult(ViewerState.DUPLICATE_CONTENT, screenName = this.screenName, reelIdentifier = currentIdentifier, skipReason = "Same Reel Identifier (Already counted)")
        }

        // 3. Confirmed New Reel!
        lastScrollTime = currentTime
        if (currentIdentifier.isNotBlank()) {
            previousReelIdentifier = currentIdentifier
        }

        return DetectionResult(ViewerState.SCROLLED_NEW_CONTENT, screenName = this.screenName, reelIdentifier = currentIdentifier, skipReason = "New reel scroll detected")
    }

    open fun reset() {
        previousReelIdentifier = ""
        lastScrollTime = 0
    }

    companion object {
        val IGNORED_WORDS = setOf(
            "second", "seconds", "sec", "secs", "minute", "minutes", "min", "mins", "hour", "hours", "day", "days", "ago",
            "elapsed", "out", "of", "playing", "paused", "pause", "play", "progress", "bar",
            "seek", "duration", "time", "like", "likes", "liked", "dislike", "dislikes",
            "comment", "comments", "share", "shares", "remix", "audio", "sound", "music",
            "original", "double", "tap", "button", "video", "by", "views", "view", "k", "m",
            "b", "follow", "following", "subscribe", "subscribed", "subscribers", "more",
            "less", "reply", "replies", "shorts", "reels", "spotlight", "feed", "profile",
            "search", "home", "notifications", "menu", "tab", "image", "icon", "add", "to", "your", "story"
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

        val words = rawText.lowercase()
            .replace(Regex("[0-9]"), "")
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
