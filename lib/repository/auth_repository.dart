import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> loginWithGoogle();
  Future<void> loginWithInstagram();
  Future<void> logout();
  Future<String?> currentUser();
}

class MockAuthRepository implements AuthRepository {
  bool _isLoggedIn = false;
  String? _currentUser;

  @override
  Future<bool> isLoggedIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _isLoggedIn;
  }

  @override
  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoggedIn = true;
    _currentUser = "google_user_123";
  }

  @override
  Future<void> loginWithInstagram() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoggedIn = true;
    _currentUser = "ig_user_456";
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = false;
    _currentUser = null;
  }

  @override
  Future<String?> currentUser() async {
    return _currentUser;
  }
}
