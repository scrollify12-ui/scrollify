import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_repository.dart';

import 'package:flutter/foundation.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();
  
  bool _isWebMockLoggedIn = false;

  @override
  Future<bool> isLoggedIn() async {
    if (kIsWeb) return _isWebMockLoggedIn;
    return _auth.currentUser != null;
  }

  @override
  Future<void> loginWithGoogle() async {
    if (kIsWeb) {
      // Simulate web login delay and success
      await Future.delayed(const Duration(milliseconds: 500));
      _isWebMockLoggedIn = true;
      return;
    }
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> loginWithInstagram() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      _isWebMockLoggedIn = true;
      return;
    }
    // TODO: Implement Instagram Sign-In
    throw UnimplementedError('Instagram sign in is not yet supported in this version.');
  }

  @override
  Future<void> logout() async {
    if (kIsWeb) {
      _isWebMockLoggedIn = false;
      return;
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<String?> currentUser() async {
    if (kIsWeb) return _isWebMockLoggedIn ? "mock_web_user_123" : null;
    return _auth.currentUser?.uid;
  }
}
