// utils/patient_status_utils.dart

/// Status & warna dari nilai vital pasien.
/// ASUMSI: threshold ini masih placeholder, HARUS direview oleh
/// tenaga medis / dokter pembimbing sebelum dipakai untuk keputusan klinis.
({String label, int colorValue}) statusFromVitals(dynamic spo2, dynamic hr) {
  final spo2Val = spo2 is num ? spo2.toDouble() : double.tryParse('$spo2');
  final hrVal = hr is num ? hr.toDouble() : double.tryParse('$hr');

  if (spo2Val == null || hrVal == null) {
    return (label: 'Belum ada data', colorValue: 0xFF9E9E9E);
  }
  if (spo2Val < 92 || hrVal > 160 || hrVal < 60) {
    return (label: 'Perlu Perhatian Segera', colorValue: 0xFFEF4444);
  }
  if (spo2Val < 95 || hrVal > 140) {
    return (label: 'Perhatian', colorValue: 0xFFF59E0B);
  }
  return (label: 'Normal', colorValue: 0xFF22C55E);
}

/// Skor keparahan untuk sorting: makin tinggi makin urgent.
/// 2 = Perlu Perhatian Segera, 1 = Perhatian, 0 = Normal, -1 = Belum ada data.
int severityScore(dynamic spo2, dynamic hr) {
  final status = statusFromVitals(spo2, hr);
  switch (status.label) {
    case 'Perlu Perhatian Segera':
      return 2;
    case 'Perhatian':
      return 1;
    case 'Normal':
      return 0;
    default:
      return -1;
  }
}