import 'package:flutter/material.dart';
import 'models/search_user_model.dart';
import 'widgets/friend_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends StatelessWidget {
  final SearchUserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(user.username, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profilePhoto!)
                  : null,
              child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '@${user.username}',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('Points', user.points.toString()),
                const SizedBox(width: 24),
                _buildStat('Streak', '${user.streak} 🔥'),
              ],
            ),
            const SizedBox(height: 32),
            FriendButton(
              targetUserId: user.id,
              initialStatus: user.friendStatus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }
}
