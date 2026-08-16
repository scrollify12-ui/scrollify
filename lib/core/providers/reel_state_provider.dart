import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/daily_stats_model.dart';
import '../../models/app_usage_model.dart';
import '../../repository/stats_repository.dart';
import '../services/native_reel_service.dart';

class ReelState {
  final DailyStatsModel dailyStats;
  final List<AppUsageModel> appUsageList;

  const ReelState({
    required this.dailyStats,
    required this.appUsageList,
  });

  factory ReelState.initial() {
    return ReelState(
      dailyStats: DailyStatsModel(
        reelsScrolledToday: 0,
        dailyLimit: 100,
        lastResetDate: DateTime.now(),
      ),
      appUsageList: _buildAppUsageList({}),
    );
  }
}

List<AppUsageModel> _buildAppUsageList(Map<String, int> counts) {
  final List<AppUsageModel> list = [];
  final apps = ['Instagram', 'YouTube', 'Facebook', 'Snapchat', 'Others'];
  
  for (var key in apps) {
    final value = counts[key] ?? 0;
    
    dynamic icon;
    Color? bgColor;
    List<Color>? gradColors;
    Color fgColor = Colors.white;

    if (key == 'Instagram') {
      icon = FontAwesomeIcons.instagram;
      gradColors = const [Color(0xFFF56040), Color(0xFFFD1D1D), Color(0xFF833AB4)];
    } else if (key == 'YouTube') {
      icon = FontAwesomeIcons.youtube;
      bgColor = const Color(0xFFFF0000);
    } else if (key == 'Facebook') {
      icon = FontAwesomeIcons.facebookF;
      bgColor = const Color(0xFF1877F2);
    } else if (key == 'Snapchat') {
      icon = FontAwesomeIcons.snapchat;
      bgColor = const Color(0xFFFFFC00);
      fgColor = Colors.black;
    } else {
      icon = Icons.more_horiz;
      bgColor = const Color(0xFF333333);
    }
    list.add(AppUsageModel(
      id: key,
      appName: key,
      reelsCount: value,
      iconData: icon,
      iconColor: bgColor,
      iconColors: gradColors,
      iconFgColor: fgColor,
      progress: value / 100.0,
    ));
  }

  // Sort descending by count, but keep order if 0
  list.sort((a, b) => b.reelsCount.compareTo(a.reelsCount));
  return list;
}

class ReelStateNotifier extends Notifier<ReelState> {
  StreamSubscription? _subscription;
  bool _initialized = false;
  Map<String, int> _previousCounts = {};

  @override
  ReelState build() {
    print('Accessibility initialized');
    
    // Start listening immediately
    _subscription?.cancel();
    _subscription = nativeReelService.reelCountsStream.listen((counts) {
      if (!_initialized) {
        _initialized = true;
      }
      
      final total = counts['Daily'] ?? counts['Total'] ?? 0;
      
      print('\nDetected Reel:');
      print('Today\'s Total: $total');
      print('Instagram: ${counts['Instagram'] ?? 0}');
      print('YouTube: ${counts['YouTube'] ?? 0}');
      print('Facebook: ${counts['Facebook'] ?? 0}');
      print('Snapchat: ${counts['Snapchat'] ?? 0}');
      print('Others: ${counts['Others'] ?? 0}');
      print('notifyListeners()\n');
      print('Home Screen Rebuilt');

      // Detect which app incremented and ping backend
      if (_previousCounts.isNotEmpty) {
        for (var entry in counts.entries) {
          final appName = entry.key;
          final count = entry.value;
          if (appName != 'Daily' && appName != 'Total') {
            final prevCount = _previousCounts[appName] ?? 0;
            if (count > prevCount) {
              final statsRepo = ref.read(statsRepositoryProvider);
              statsRepo.incrementReelCount(appName);
            }
          }
        }
      }
      _previousCounts = Map.from(counts);

      state = ReelState(
        dailyStats: DailyStatsModel(
          reelsScrolledToday: total,
          dailyLimit: 100,
          lastResetDate: DateTime.now(),
        ),
        appUsageList: _buildAppUsageList(counts),
      );
    });
    
    // Return initial state immediately so UI doesn't show loading
    return ReelState.initial();
  }
}

final reelStateProvider = NotifierProvider<ReelStateNotifier, ReelState>(() {
  return ReelStateNotifier();
});
