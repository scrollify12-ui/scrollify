import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository();
});

abstract class ProfileRepository {
  Future<bool> isProfileComplete();
  Future<bool> isUsernameUnique(String username);
  Future<String?> uploadProfilePhoto(File imageFile);
  Future<void> completeProfile({
    required String fullName,
    required String username,
    required String? instagramHandle,
    required String? profilePhotoUrl,
  });
}

class MockProfileRepository implements ProfileRepository {
  bool _isComplete = false;

  @override
  Future<bool> isProfileComplete() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _isComplete;
  }

  @override
  Future<bool> isUsernameUnique(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<String?> uploadProfilePhoto(File imageFile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return "https://mock-image-url.com/photo.jpg";
  }

  @override
  Future<void> completeProfile({
    required String fullName,
    required String username,
    required String? instagramHandle,
    required String? profilePhotoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _isComplete = true;
  }
}
