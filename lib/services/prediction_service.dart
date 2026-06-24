// lib/services/prediction_service.dart
//
// Layer di antara UI Flutter dan ApiService. Menangani loading state,
// error handling, dan retry otomatis.

import 'package:flutter/foundation.dart';
import 'api_service.dart';

enum PredictionStatus { idle, loading, success, error }

class PredictionService extends ChangeNotifier {
  PredictionStatus status = PredictionStatus.idle;
  Map<String, dynamic>? lastResult;
  String? errorMessage;

  static const int _maxRetries = 2;

  Future<void> fetchPrediction({
    required String childId,
    required int age,
    required double weight,
    required double height,
    required double spo2,
    required double hr,
    String? deviceToken,
    String? childName,
  }) async {
    status = PredictionStatus.loading;
    errorMessage = null;
    notifyListeners();

    int attempt = 0;
    while (true) {
      try {
        final result = await ApiService.predictRisk(
          childId: childId,
          age: age,
          weight: weight,
          height: height,
          spo2: spo2,
          hr: hr,
          deviceToken: deviceToken,
          childName: childName,
        );
        lastResult = result;
        status = PredictionStatus.success;
        notifyListeners();
        return;
      } catch (e) {
        attempt++;
        if (attempt > _maxRetries) {
          status = PredictionStatus.error;
          errorMessage = e.toString();
          notifyListeners();
          return;
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }

  Future<List<dynamic>> fetchHistory(String childId) async {
    return ApiService.getHistory(childId);
  }

  void reset() {
    status = PredictionStatus.idle;
    lastResult = null;
    errorMessage = null;
    notifyListeners();
  }
}