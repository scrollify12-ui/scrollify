package com.scrollz.app.detectors

class YoutubeDetector : ReelDetector() {
    override val targetPackage = "com.google.android.youtube"
    override val screenName = "YouTube Shorts"
}
