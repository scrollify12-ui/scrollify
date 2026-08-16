import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String firebaseUid;
  final String fullName;
  final String username;
  final String email;
  final String? profilePhoto;
  final String? instagramHandle;
  final int points;
  final int currentStreak;
  final int friendsCount;
  final int badgesCount;
  final int walletBalance;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.fullName,
    required this.username,
    required this.email,
    this.profilePhoto,
    this.instagramHandle,
    this.points = 0,
    this.currentStreak = 0,
    this.friendsCount = 0,
    this.badgesCount = 0,
    this.walletBalance = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      instagramHandle: json['instagramHandle'] as String?,
      points: json['points'] as int? ?? 0,
      currentStreak: json['streak'] as int? ?? 0,
      friendsCount: json['friendsCount'] as int? ?? 0,
      badgesCount: json['badgesCount'] as int? ?? 0,
      walletBalance: json['walletBalance'] as int? ?? (json['points'] as int? ?? 0),
    );
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? fullName,
    String? username,
    String? email,
    String? profilePhoto,
    String? instagramHandle,
    int? points,
    int? currentStreak,
    int? friendsCount,
    int? badgesCount,
    int? walletBalance,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      points: points ?? this.points,
      currentStreak: currentStreak ?? this.currentStreak,
      friendsCount: friendsCount ?? this.friendsCount,
      badgesCount: badgesCount ?? this.badgesCount,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
