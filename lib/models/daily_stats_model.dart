class DailyStatsModel {
  final int reelsScrolledToday;
  final int dailyLimit;
  final DateTime lastResetDate;

  const DailyStatsModel({
    required this.reelsScrolledToday,
    required this.dailyLimit,
    required this.lastResetDate,
  });

  DailyStatsModel copyWith({
    int? reelsScrolledToday,
    int? dailyLimit,
    DateTime? lastResetDate,
  }) {
    return DailyStatsModel(
      reelsScrolledToday: reelsScrolledToday ?? this.reelsScrolledToday,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  int get reelsRemaining => dailyLimit - reelsScrolledToday;
  double get progressFraction => reelsScrolledToday / dailyLimit;
}
