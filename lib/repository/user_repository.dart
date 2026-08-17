import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

class UserRepository {
  final ApiClient _apiClient;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.5:3000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  UserRepository(this._apiClient);

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<UserModel> getCurrentUser() async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    try {
      print('Sending GET api/users/profile');
      final response = await _dio.get(
        'users/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('GET api/users/profile');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.data}');
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      
      throw Exception('Failed to load user profile: ${response.statusCode}');
    } catch (e) {
      print('Real exception loading profile: $e');
      throw Exception('Network error fetching user profile: $e');
    }
  }

  Future<List<UserModel>> getLeaderboard(String filter) async {
    await _apiClient.simulateNetworkDelay();
    return const [];
  }
}
