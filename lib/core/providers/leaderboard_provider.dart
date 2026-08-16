import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../repository/user_repository.dart';

final leaderboardFilterProvider = StateProvider<String>((ref) => 'Today');

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final filter = ref.watch(leaderboardFilterProvider);
  return await repo.getLeaderboard(filter);
});
