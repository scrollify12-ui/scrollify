import 'package:flutter/material.dart';

class RewardModel {
  final String id;
  final String title;
  final String subtitle;
  final int pointsCost;
  final Widget icon;

  const RewardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pointsCost,
    required this.icon,
  });
}
