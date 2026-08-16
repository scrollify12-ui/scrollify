import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.5:3000/api', // Using PC's local Wi-Fi IP
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  FirebaseAuth get _auth => FirebaseAuth.instance;
  
  bool _isProfileCached = false; // Simple in-memory cache to skip repeated network calls if already verified

  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  @override
  Future<bool> isProfileComplete() async {
    if (_isProfileCached) return true;
    
    final token = await _getIdToken();
    if (token == null) return false;

    try {
      // We ping the sync endpoint. If the user doesn't exist, it requires a body and will return 400.
      // If the user exists, it updates lastLogin and returns 200 with the user object.
      // But we just want to check if they exist right now without providing body data.
      // Since our sync endpoint in Node.js creates if missing (but fails due to missing body),
      // returning a 400 means they don't exist yet! Returning a 200 means they exist.
      
      final response = await _dio.post(
        '/auth/sync',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {}, // empty data
      );

      if (response.statusCode == 200) {
        _isProfileCached = true;
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
         // Missing required fields (which means it tried to create a user and failed because they didn't exist)
         return false;
      }
      // Network or other error
      return false;
    }
  }

  @override
  Future<bool> isUsernameUnique(String username) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await _dio.get(
        '/users/check-username',
        queryParameters: {'username': username},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data['available'] == true;
      }
      throw Exception('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error or API failure: ${e.message}');
    } catch (e) {
      throw Exception('Unable to verify username: $e');
    }
  }

  @override
  Future<String?> uploadProfilePhoto(File imageFile) async {
    // Firebase Storage has been removed as per requirements.
    // For now, we do not upload the image anywhere.
    // In the future, this can be wired to Cloudinary or AWS S3.
    return null;
  }

  @override
  Future<void> completeProfile({
    required String fullName,
    required String username,
    required String? instagramHandle,
    required String? profilePhotoUrl,
  }) async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('Cannot complete profile: No user is currently logged in.');
    }

    try {
      final response = await _dio.post(
        '/auth/sync',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'fullName': fullName,
          'username': username.toLowerCase(),
          'instagramHandle': instagramHandle,
          'profilePhoto': profilePhotoUrl,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isProfileCached = true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Username is already taken');
      }
      throw Exception('Failed to complete profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to complete profile: $e');
    }
  }
}
