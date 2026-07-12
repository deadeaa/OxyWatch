import 'package:flutter/material.dart';

class RiskScoreModel {
  final String level; // NORMAL, WASPADA, BAHAYA
  final int score;
  final String color; // green, amber, red
  final String spo2Status; // normal, waspada, bahaya
  final String hrStatus; // normal, waspada, bahaya
  final String recommendation;
  final String explanation;
  final List<String> tips;

  RiskScoreModel({
    required this.level,
    required this.score,
    required this.color,
    required this.spo2Status,
    required this.hrStatus,
    required this.recommendation,
    required this.explanation,
    required this.tips,
  });

  factory RiskScoreModel.fromMap(Map<String, dynamic> map) {
    return RiskScoreModel(
      level: map['level'] ?? 'NORMAL',
      score: map['score'] ?? 0,
      color: map['color'] ?? 'green',
      spo2Status: map['spo2_status'] ?? 'normal',
      hrStatus: map['hr_status'] ?? 'normal',
      recommendation: map['recommendation'] ?? '',
      explanation: map['explanation'] ?? '',
      tips: List<String>.from(map['tips'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'score': score,
      'color': color,
      'spo2_status': spo2Status,
      'hr_status': hrStatus,
      'recommendation': recommendation,
      'explanation': explanation,
      'tips': tips,
    };
  }

  Color get levelColor {
    switch (level) {
      case 'BAHAYA':
        return const Color(0xFFEF4444);
      case 'WASPADA':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  String getLevelText(bool isId) {
    switch (level) {
      case 'BAHAYA':
        return isId ? 'KRITIS' : 'CRITICAL';
      case 'WASPADA':
        return isId ? 'WASPADA' : 'WARNING';
      default:
        return isId ? 'NORMAL' : 'NORMAL';
    }
  }

  String getStatusText(String status, bool isId) {
    switch (status) {
      case 'bahaya':
        return isId ? 'Kritis' : 'Critical';
      case 'waspada':
        return isId ? 'Perlu Perhatian' : 'Needs Attention';
      default:
        return isId ? 'Normal' : 'Normal';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'bahaya':
        return Colors.red;
      case 'waspada':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}