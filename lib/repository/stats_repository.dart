import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_usage_model.dart';
import '../network/api_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(apiClientProvider));
});

class StatsRepository {
  final ApiClient _apiClient;

  StatsRepository(this._apiClient);

  Future<List<AppUsageModel>> getAppUsageStats() async {
    await _apiClient.simulateNetworkDelay();
    return const [];
  }

  Future<void> incrementReelCount(String appName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final token = await user.getIdToken();
      final dio = Dio(BaseOptions(
        baseUrl: 'http://192.168.1.5:3000/api', // Consistent with user_repository
        connectTimeout: const Duration(seconds: 10),
      ));

      // Note: Endpoint and payload may need adjusting once backend is finalized
      await dio.post(
        '/users/stats/increment',
        data: {'app': appName},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Successfully incremented backend counter for $appName');
    } catch (e) {
      print('Failed to increment backend counter for $appName: $e');
    }
  }
}
