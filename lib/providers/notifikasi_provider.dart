// providers/notifikasi_provider.dart
import 'package:flutter/material.dart';

class NotifikasiProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifikasi = [];
  int _idCounter = 5;

  NotifikasiProvider() {
    _loadNotifikasi();
  }

  void _loadNotifikasi() {
    _notifikasi = [
      {
        'id': '1',
        'title': 'SpO₂ Kritis!',
        'body': 'SpO₂ Budi turun ke 89% — 17 Jun, 02:14',
        'time': '17 Jun, 02:14',
        'read': false,
        'type': 'critical',
      },
      {
        'id': '2',
        'title': 'Detak Jantung Tinggi',
        'body': 'HR Budi mencapai 162 bpm — perlu pantauan',
        'time': '17 Jun, 02:13',
        'read': false,
        'type': 'warning',
      },
      {
        'id': '3',
        'title': 'Pesan dari Dr. Siti',
        'body': 'Tetap pantau dan beri inhalasi jika sesak.',
        'time': '09:18',
        'read': true,
        'type': 'info',
      },
      {
        'id': '4',
        'title': 'Laporan Harian Siap',
        'body': 'Laporan monitoring 16 Jun sudah tersedia.',
        'time': 'Kemarin',
        'read': true,
        'type': 'info',
      },
    ];
  }

  // 🔥 TAMBAHKAN NOTIFIKASI DARI SMARTWATCH
  void addNotification({
    required String title,
    required String body,
    required String time,
    required String type,
  }) {
    // Cek apakah notifikasi dengan title yang sama sudah ada (hindari duplikat)
    final exists = _notifikasi.any((n) =>
    n['title'] == title &&
        n['body'] == body &&
        n['read'] == false
    );

    if (!exists) {
      _notifikasi.insert(0, {
        'id': '${_idCounter++}',
        'title': title,
        'body': body,
        'time': time,
        'read': false,
        'type': type,
      });
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getAllNotifikasi() => _notifikasi;

  List<Map<String, dynamic>> getBelumDibaca() =>
      _notifikasi.where((n) => !n['read']).toList();

  List<Map<String, dynamic>> getSudahDibaca() =>
      _notifikasi.where((n) => n['read']).toList();

  int get belumDibaca => _notifikasi.where((n) => !n['read']).length;

  int get sudahDibaca => _notifikasi.where((n) => n['read']).length;

  void markAsRead(String id) {
    final index = _notifikasi.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifikasi[index]['read'] = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifikasi) {
      n['read'] = true;
    }
    notifyListeners();
  }
}