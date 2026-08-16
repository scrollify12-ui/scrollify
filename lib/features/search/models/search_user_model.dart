class SearchUserModel {
  final String id;
  final String fullName;
  final String username;
  final String? profilePhoto;
  final int points;
  final int streak;
  final String friendStatus;

  SearchUserModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePhoto,
    required this.points,
    required this.streak,
    required this.friendStatus,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      points: json['points'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      friendStatus: json['friendStatus'] as String? ?? 'none',
    );
  }
}
