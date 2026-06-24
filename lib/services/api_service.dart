// lib/services/api_service.dart
//
// HTTP client ke FastAPI backend. Anggota 2 tinggal panggil
// ApiService.predictRisk(...) atau ApiService.getHistory(...) —
// tidak perlu tahu detail HTTP/JSON di balik layar.
//
// PENTING: setelah Railway live (Minggu 3), ganti nilai `baseUrl`
// di bawah dengan URL publik dari Railway.

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: ganti dengan URL Railway setelah deploy, contoh:
  // static const String baseUrl = "https://oxywatch-backend.up.railway.app";
  static const String baseUrl = "http://localhost:8000";

  /// Kirim data sensor ke backend, dapat hasil klasifikasi risiko.
  static Future<Map<String, dynamic>> predictRisk({
    required String childId,
    required int age,
    required double weight,
    required double height,
    required double spo2,
    required double hr,
    String? deviceToken,
    String? childName,
  }) async {
    final uri = Uri.parse("$baseUrl/predict");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "child_id": childId,
        "age": age,
        "weight": weight,
        "height": height,
        "spo2": spo2,
        "hr": hr,
        if (deviceToken != null) "device_token": deviceToken,
        if (childName != null) "child_name": childName,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        "Gagal mengambil prediksi (${response.statusCode}): ${response.body}",
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Ambil riwayat sensor + prediksi untuk satu anak.
  static Future<List<dynamic>> getHistory(String childId, {int limit = 50}) async {
    final uri = Uri.parse("$baseUrl/children/$childId/history?limit=$limit");
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw ApiException(
        "Gagal mengambil riwayat (${response.statusCode}): ${response.body}",
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data["history"] as List<dynamic>;
  }

  /// Dokter mengirim catatan rekomendasi untuk seorang anak.
  static Future<void> postRecommendation({
    required String childId,
    required String doctorId,
    required String note,
  }) async {
    final uri = Uri.parse("$baseUrl/recommendation");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "child_id": childId,
        "doctor_id": doctorId,
        "note": note,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        "Gagal mengirim rekomendasi (${response.statusCode}): ${response.body}",
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}