// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 🔥 GANTI DENGAN IP MAC KAMU (nanti di update)
  static const String baseUrl = 'http://192.168.1.100:8000';

  Future<Map<String, dynamic>> predictRisk({
    required String childId,
    required int age,
    required double weight,
    required double height,
    required double spo2,
    required double hr,
    String? deviceToken,
    String? childName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': childId,
          'age': age,
          'weight': weight,
          'height': height,
          'spo2': spo2,
          'hr': hr,
          'device_token': deviceToken,
          'child_name': childName ?? 'Anak',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('AI Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calling AI: $e');
    }
  }

  Future<List<dynamic>> getHistory(String childId, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/children/$childId/history?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['history'] ?? [];
      } else {
        throw Exception('Failed to get history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting history: $e');
    }
  }

  Future<void> sendRecommendation({
    required String childId,
    required String doctorId,
    required String note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': childId,
          'doctor_id': doctorId,
          'note': note,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send recommendation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending recommendation: $e');
    }
  }
}