import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      return docSnapshot.exists;
    } catch (e) {
      // In case of any network or permission error, default to false
      return false;
    }
  }

  @override
  Future<bool> isUsernameUnique(String username) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      return false;
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
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Cannot complete profile: No user is currently logged in.');
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': fullName,
        'username': username.toLowerCase(),
        'instagramHandle': instagramHandle,
        'profilePhotoUrl': profilePhotoUrl,
        'email': user.email ?? '',
        'points': 1250, // Initial points
        'currentStreak': 5,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to complete profile: $e');
    }
  }
}
