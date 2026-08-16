import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';
import '../network/api_client.dart';
import '../network/api_error.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository(ref.watch(apiClientProvider));
});

class RewardRepository {
  final ApiClient _apiClient;

  RewardRepository(this._apiClient);

  Future<List<RewardModel>> getAvailableRewards() async {
    await _apiClient.simulateNetworkDelay();
    return [
      RewardModel(id: '1', title: 'Amazon Voucher', subtitle: '₹100', pointsCost: 5500, icon: Image.asset('assets/images/amazon_logo.png', width: 32, height: 32)),
      RewardModel(id: '2', title: 'Google Play Gift Card', subtitle: '₹100', pointsCost: 5000, icon: Image.asset('assets/images/google_play_logo.png', width: 32, height: 32)),
      RewardModel(id: '3', title: 'UPI Cash', subtitle: '₹50', pointsCost: 2800, icon: Image.asset('assets/images/upi_logo.png', width: 32, height: 32)),
    ];
  }

  Future<bool> redeemReward(String rewardId, int pointsCost, int currentPoints) async {
    await _apiClient.simulateNetworkDelay();
    if (currentPoints < pointsCost) {
      throw ApiError(message: 'Not enough points');
    }
    // Simulate successful redemption
    return true;
  }
}
