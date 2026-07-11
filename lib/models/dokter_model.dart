// lib/models/dokter_model.dart
class Dokter {
  final String id;
  final String nama;
  final String spesialis;
  final String foto;
  final bool online;
  final String lastActive;
  final double rating;
  final int totalPasien;
  final String rumahSakit;

  Dokter({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.foto,
    required this.online,
    required this.lastActive,
    required this.rating,
    required this.totalPasien,
    required this.rumahSakit,
  });
}