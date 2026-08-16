import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/search_user_model.dart';

class SearchRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.5:3000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<List<SearchUserModel>> getSuggestedUsers() async {
    print('[SEARCH-REPO] Fetching suggested users...');
    final token = await _getIdToken();
    if (token == null) {
      print('[SEARCH-REPO] ERROR: No auth token for suggestions!');
      return [];
    }

    try {
      final response = await _dio.get(
        '/users/suggestions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        if (response.data is! List) return [];
        final List<dynamic> data = response.data;
        
        final results = <SearchUserModel>[];
        for (int i = 0; i < data.length; i++) {
          try {
            results.add(SearchUserModel.fromJson(data[i] as Map<String, dynamic>));
          } catch (e) {
            print('[SEARCH-REPO] Error parsing suggestion: $e');
          }
        }
        return results;
      }
      return [];
    } catch (e) {
      print('[SEARCH-REPO] Error fetching suggestions: $e');
      return [];
    }
  }

  Future<List<SearchUserModel>> searchUsers(String query) async {
    if (query.trim().length < 2) return [];

    print('[SEARCH-REPO] Getting Firebase token...');
    final token = await _getIdToken();
    if (token == null) {
      print('[SEARCH-REPO] ERROR: No auth token!');
      throw Exception('User not authenticated');
    }
    print('[SEARCH-REPO] Token obtained (${token.length} chars)');

    final url = '/users/search?q=${Uri.encodeComponent(query.trim())}';
    print('[SEARCH-REPO] API URL: ${_dio.options.baseUrl}$url');
    print('[SEARCH-REPO] Sending GET request...');

    try {
      final response = await _dio.get(
        '/users/search',
        queryParameters: {'q': query.trim()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('[SEARCH-REPO] Status Code: ${response.statusCode}');
      print('[SEARCH-REPO] Response Type: ${response.data.runtimeType}');
      print('[SEARCH-REPO] Response Body: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! List) {
          print('[SEARCH-REPO] ERROR: Response is not a List! Got: ${response.data.runtimeType}');
          return [];
        }

        final List<dynamic> data = response.data;
        print('[SEARCH-REPO] Parsing ${data.length} users...');

        final results = <SearchUserModel>[];
        for (int i = 0; i < data.length; i++) {
          try {
            final user = SearchUserModel.fromJson(data[i] as Map<String, dynamic>);
            results.add(user);
          } catch (e) {
            print('[SEARCH-REPO] ERROR parsing user at index $i: $e');
            print('[SEARCH-REPO] Raw JSON: ${data[i]}');
            // Skip this user and continue
          }
        }

        print('[SEARCH-REPO] Successfully parsed ${results.length} users');
        return results;
      }

      print('[SEARCH-REPO] Unexpected status: ${response.statusCode}');
      throw Exception('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      print('[SEARCH-REPO] DioException: ${e.type} - ${e.message}');
      print('[SEARCH-REPO] DioException response: ${e.response?.data}');
      throw Exception('Search API error: ${e.message}');
    } catch (e) {
      print('[SEARCH-REPO] General Exception: $e');
      throw Exception('Unable to search users: $e');
    }
  }

  Future<String> sendFriendRequest(String targetUserId) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final response = await _dio.post(
        '/friends/request',
        data: {'targetUserId': targetUserId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['status'] as String;
      }
      throw Exception('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Friend Request API error: ${e.response?.data?['error'] ?? e.message}');
    } catch (e) {
      throw Exception('Unable to send request: $e');
    }
  }
}
