import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reward_model.dart';
import '../../repository/reward_repository.dart';

final rewardsProvider = FutureProvider<List<RewardModel>>((ref) async {
  final repo = ref.watch(rewardRepositoryProvider);
  return await repo.getAvailableRewards();
});
