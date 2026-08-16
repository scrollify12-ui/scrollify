import 'package:flutter/material.dart';

class AppUsageModel {
  final String id;
  final String appName;
  final int reelsCount;
  final dynamic iconData;
  final Color? iconColor;
  final Color? iconFgColor;
  final List<Color>? iconColors;
  final double progress; // fractional value 0.0 - 1.0

  const AppUsageModel({
    required this.id,
    required this.appName,
    required this.reelsCount,
    required this.iconData,
    this.iconColor,
    this.iconFgColor,
    this.iconColors,
    required this.progress,
  });
}
