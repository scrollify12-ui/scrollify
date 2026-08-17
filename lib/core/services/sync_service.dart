import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../network/api_client.dart';
import '../storage/local_storage_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(localStorageProvider).prefs;
  return SyncService(apiClient.dio, prefs);
});

class SyncService {
  final Dio _dio;
  final SharedPreferences _prefs;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._dio, this._prefs) {
    // Start periodic sync every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncReels();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  Future<void> syncReels() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final int instagram = _prefs.getInt('flutter.unSyncedReels_Instagram') ?? 0;
      final int youtube = _prefs.getInt('flutter.unSyncedReels_YouTube') ?? 0;
      final int facebook = _prefs.getInt('flutter.unSyncedReels_Facebook') ?? 0;
      final int snapchat = _prefs.getInt('flutter.unSyncedReels_Snapchat') ?? 0;

      final totalDelta = instagram + youtube + facebook + snapchat;

      if (totalDelta == 0) {
        _isSyncing = false;
        return;
      }

      // Check if user is logged in
      final token = await _getToken();
      if (token == null) {
        _isSyncing = false;
        return;
      }

      final response = await _dio.post(
        'users/sync-reels',
        data: {
          'instagram': instagram,
          'youtube': youtube,
          'facebook': facebook,
          'snapchat': snapchat,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Successfully synced, deduct the exact amounts we just sent
        // (In case more were added while the request was in flight)
        _deductSyncedCount('flutter.unSyncedReels_Instagram', instagram);
        _deductSyncedCount('flutter.unSyncedReels_YouTube', youtube);
        _deductSyncedCount('flutter.unSyncedReels_Facebook', facebook);
        _deductSyncedCount('flutter.unSyncedReels_Snapchat', snapchat);
      }
    } catch (e) {
      print('Sync failed: $e');
      // Do nothing, will retry next time
    } finally {
      _isSyncing = false;
    }
  }

  void _deductSyncedCount(String key, int amount) {
    final current = _prefs.getInt(key) ?? 0;
    final newCount = (current - amount).clamp(0, 999999);
    _prefs.setInt(key, newCount);
  }

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }
}
