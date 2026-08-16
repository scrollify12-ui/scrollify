import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider not initialized');
});

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyReelsScrolledToday = 'reelsScrolledToday';
  static const String _keyLastResetDate = 'lastResetDate';
  static const String _keyUserPoints = 'userPoints';
  static const String _keyCurrentStreak = 'currentStreak';

  // --- Daily Stats ---
  
  int getReelsScrolledToday() {
    return _prefs.getInt(_keyReelsScrolledToday) ?? 0;
  }

  Future<void> setReelsScrolledToday(int count) async {
    await _prefs.setInt(_keyReelsScrolledToday, count);
  }

  DateTime? getLastResetDate() {
    final dateStr = _prefs.getString(_keyLastResetDate);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  Future<void> setLastResetDate(DateTime date) async {
    await _prefs.setString(_keyLastResetDate, date.toIso8601String());
  }

  // --- User Stats ---

  int getUserPoints() {
    return _prefs.getInt(_keyUserPoints) ?? 1250; // Default points from mockup
  }

  Future<void> setUserPoints(int points) async {
    await _prefs.setInt(_keyUserPoints, points);
  }

  int getCurrentStreak() {
    return _prefs.getInt(_keyCurrentStreak) ?? 5; // Default streak
  }

  Future<void> setCurrentStreak(int streak) async {
    await _prefs.setInt(_keyCurrentStreak, streak);
  }
}
