import 'dart:async';
import 'package:flutter/services.dart';

class NativeReelService {
  static const MethodChannel _methodChannel = MethodChannel('com.scrollz.app/methods');
  static const EventChannel _eventChannel = EventChannel('com.scrollz.app/reel_events');

  // Stream of reel counts mapped by app name
  Stream<Map<String, int>> get reelCountsStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      final map = Map<String, dynamic>.from(event);
      return map.map((key, value) => MapEntry(key, (value as num).toInt()));
    });
  }

  // Check if accessibility permission is granted
  Future<bool> checkAccessibilityPermission() async {
    try {
      final bool hasPermission = await _methodChannel.invokeMethod('checkAccessibilityPermission');
      return hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Open settings for the user to grant permission
  Future<void> openAccessibilitySettings() async {
    try {
      await _methodChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      // Ignore
    }
  }
}

final nativeReelService = NativeReelService();
