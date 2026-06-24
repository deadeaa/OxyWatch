// lib/utils/risk_helper.dart
//
// Helper functions yang dipakai di SEMUA screen yang menampilkan level
// risiko: Dashboard, Riwayat, Alert, Detail Pasien, dll.

import 'package:flutter/material.dart';

String _normalize(String level) => level.toUpperCase().trim();

Color riskColor(String level) {
  switch (_normalize(level)) {
    case "BAHAYA":
      return const Color(0xFFE53935); // merah
    case "WASPADA":
      return const Color(0xFFFFA726); // amber/kuning
    case "NORMAL":
    default:
      return const Color(0xFF43A047); // hijau
  }
}

String riskLabel(String level) {
  switch (_normalize(level)) {
    case "BAHAYA":
      return "Bahaya";
    case "WASPADA":
      return "Waspada";
    case "NORMAL":
    default:
      return "Normal";
  }
}

IconData riskIcon(String level) {
  switch (_normalize(level)) {
    case "BAHAYA":
      return Icons.error;
    case "WASPADA":
      return Icons.warning_amber_rounded;
    case "NORMAL":
    default:
      return Icons.check_circle;
  }
}