import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    final String apiUrl = (kReleaseMode || kIsWeb)
        ? 'https://scrollify-backend.onrender.com/api/'
        : 'http://192.168.1.5:3000/api/';

    _dio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth tokens here if needed
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Handle global errors here
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
  
  // Helper to simulate network delay for mock endpoints
  Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
