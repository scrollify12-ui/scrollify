import 'package:flutter/material.dart';
import '../home/widgets/home_header.dart'; // Reusing header from home
import 'widgets/points_summary_card.dart';
import 'widgets/rewards_list.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    PointsSummaryCard(),
                    SizedBox(height: 16),
                    RewardsList(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
