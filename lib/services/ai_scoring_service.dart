import 'dart:math';

class AIScoringService {
  static const double SPO2_NORMAL_MIN = 95;
  static const double SPO2_WASPADA_MIN = 92;

  // Sumber: PALS Guidelines 2015 (Pediatric Advanced Life Support)
  static const Map<int, List<int>> _hrReference = {
    2: [98, 140], // Toddler
    3: [80, 120], // Preschool
    4: [80, 120], // Preschool
    5: [80, 120], // Preschool
  };
  static const List<int> _hrDefaultRange = [80, 120];

  // ========== CLASSIFICATION ==========

  static String _classifySpo2(double spo2) {
    if (spo2 >= SPO2_NORMAL_MIN) return 'normal';
    if (spo2 >= SPO2_WASPADA_MIN) return 'waspada';
    return 'bahaya';
  }

  static String _classifyHr(int age, double hr) {
    final range = _hrReference[age] ?? _hrDefaultRange;
    final hrMin = range[0];
    final hrMax = range[1];

    if (hrMin <= hr && hr <= hrMax) return 'normal';
    if (hr < hrMin - 10 || hr > hrMax + 20) return 'bahaya';
    return 'waspada';
  }

  // ========== GENERATE EXPLANATION ==========

  static Map<String, dynamic> _generateExplanation({
    required double spo2,
    required double hr,
    required String level,
    required String spo2Status,
    required String hrStatus,
    required bool isEnglish,
  }) {
    final parts = <String>[];

    // SpO2 part
    if (spo2Status == 'bahaya') {
      parts.add(isEnglish
          ? 'Blood oxygen levels are quite low ($spo2%)'
          : 'Kadar oksigen darahnya turun cukup rendah ($spo2%)');
    } else if (spo2Status == 'waspada') {
      parts.add(isEnglish
          ? 'Blood oxygen levels are slightly low ($spo2%)'
          : 'Kadar oksigen darahnya agak turun ($spo2%)');
    } else {
      parts.add(isEnglish
          ? 'Blood oxygen levels are good ($spo2%)'
          : 'Kadar oksigen darahnya bagus ($spo2%)');
    }

    // HR part
    if (hrStatus == 'bahaya') {
      parts.add(isEnglish
          ? 'heart rate is also outside normal range ($hr bpm)'
          : 'detak jantungnya juga di luar batas wajar ($hr bpm)');
    } else if (hrStatus == 'waspada') {
      parts.add(isEnglish
          ? 'heart rate is slightly outside normal range ($hr bpm)'
          : 'detak jantungnya sedikit di luar rentang normal ($hr bpm)');
    } else {
      parts.add(isEnglish
          ? 'heart rate is normal ($hr bpm)'
          : 'detak jantungnya normal ($hr bpm)');
    }

    final explanation = '${parts.join(' and ')}.';

    // Tips berdasarkan level
    List<String> tips;
    if (level == 'BAHAYA') {
      tips = isEnglish
          ? [
        'Immediately check the child\'s condition, look for signs of shortness of breath or weakness.',
        'Stay calm, sit or bring the child to a comfortable position.',
        'Contact a doctor or go to the nearest healthcare facility immediately.',
        'Don\'t wait for the condition to worsen before acting.',
      ]
          : [
        'Segera periksa kondisi anak secara langsung, lihat apakah ada tanda sesak atau lemas.',
        'Tetap tenang, dudukkan atau bawa anak ke posisi yang nyaman.',
        'Hubungi dokter atau langsung ke fasilitas kesehatan terdekat sekarang.',
        'Jangan tunggu kondisi memburuk sebelum bertindak.',
      ];
    } else if (level == 'WASPADA') {
      tips = isEnglish
          ? [
        'Monitor the child more frequently in the next 15-30 minutes.',
        'Make sure the child rests enough and avoids strenuous activities.',
        'Check SpO2 and heart rate again in a moment.',
        'If it doesn\'t improve or worsens, contact a doctor.',
      ]
          : [
        'Pantau anak lebih sering dalam 15-30 menit ke depan.',
        'Pastikan anak istirahat cukup dan tidak banyak aktivitas berat.',
        'Cek ulang SpO2 dan detak jantung beberapa saat lagi.',
        'Kalau belum membaik atau malah memburuk, hubungi dokter.',
      ];
    } else {
      tips = isEnglish
          ? [
        'Condition is good, continue normal activities.',
        'Continue routine monitoring as scheduled.',
      ]
          : [
        'Kondisinya bagus, lanjutkan aktivitas seperti biasa.',
        'Tetap pantau secara rutin sesuai jadwal monitoring.',
      ];
    }

    return {
      'explanation': explanation,
      'tips': tips,
    };
  }

  // ========== GENERATE RECOMMENDATION ==========

  static String _recommendation(String level, bool isEnglish) {
    if (level == 'bahaya') {
      return isEnglish
          ? 'Immediately check the child directly. If SpO2 remains low or the child appears short of breath/weak, contact a doctor or the nearest healthcare facility now.'
          : 'Segera periksa anak secara langsung. Jika SpO2 tetap rendah atau anak terlihat sesak/lemas, hubungi dokter atau fasilitas kesehatan terdekat sekarang.';
    } else if (level == 'waspada') {
      return isEnglish
          ? 'Monitor the child more frequently in the next 15-30 minutes. Make sure the child is in a comfortable position and gets enough rest. If the condition does not improve, contact a doctor.'
          : 'Pantau anak lebih sering dalam 15-30 menit ke depan. Pastikan anak dalam posisi nyaman dan cukup istirahat. Jika kondisi tidak membaik, hubungi dokter.';
    } else {
      return isEnglish
          ? 'The child\'s condition is normal. Continue routine monitoring as usual.'
          : 'Kondisi anak normal. Lanjutkan pemantauan rutin seperti biasa.';
    }
  }

  // ========== MAIN PREDICT FUNCTION ==========

  static Map<String, dynamic> predict({
    required int age,
    required double weight,
    required double height,
    required double spo2,
    required double hr,
    bool isEnglish = false,
  }) {
    final spo2Status = _classifySpo2(spo2);
    final hrStatus = _classifyHr(age, hr);

    String level;
    int score;
    String color;

    if (spo2Status == 'bahaya' || hrStatus == 'bahaya') {
      level = 'BAHAYA';
      score = 90;
      color = 'red';
    } else if (spo2Status == 'waspada' || hrStatus == 'waspada') {
      level = 'WASPADA';
      score = 55;
      color = 'amber';
    } else {
      level = 'NORMAL';
      score = 15;
      color = 'green';
    }

    final explanationData = _generateExplanation(
      spo2: spo2,
      hr: hr,
      level: level,
      spo2Status: spo2Status,
      hrStatus: hrStatus,
      isEnglish: isEnglish,
    );

    return {
      'level': level,
      'score': score,
      'color': color,
      'spo2_status': spo2Status,
      'hr_status': hrStatus,
      'recommendation': _recommendation(
        level.toLowerCase(),
        isEnglish,
      ),
      'explanation': explanationData['explanation'],
      'tips': explanationData['tips'],
    };
  }
}