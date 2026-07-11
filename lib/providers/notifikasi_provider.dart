// providers/notifikasi_provider.dart
import 'package:flutter/material.dart';

class NotifikasiProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifikasi = [];

  NotifikasiProvider() {
    _loadNotifikasi();
  }

  void _loadNotifikasi() {
    _notifikasi = [
      {
        'id': '1',
        'title': 'SpO₂ Kritis!',
        'body': 'SpO₂ Budi turun ke 89% — perlu tindakan segera',
        'time': '17 Jun, 02:14',
        'read': false,
      },
      {
        'id': '2',
        'title': 'Detak Jantung Tinggi',
        'body': 'HR Budi mencapai 162 bpm — perlu pantauan',
        'time': '17 Jun, 02:13',
        'read': false,
      },
      {
        'id': '3',
        'title': 'Pesan dari Dr. Siti',
        'body': 'Tetap pantau dan beri inhalasi jika sesak.',
        'time': '09:18',
        'read': true,
      },
      {
        'id': '4',
        'title': 'Laporan Harian Siap',
        'body': 'Laporan monitoring 16 Jun sudah tersedia.',
        'time': 'Kemarin',
        'read': true,
      },
    ];
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