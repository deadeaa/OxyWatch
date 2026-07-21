// services/code_generator_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CodeGeneratorService {
  CodeGeneratorService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateUserCode(UserRole role) async {
    final String counterName;
    final String prefix;

    switch (role) {
      case UserRole.parent:
        counterName = 'parent_counter';
        prefix = 'P';
        break;
      case UserRole.doctor:
        counterName = 'doctor_counter';
        prefix = 'D';
        break;
    }

    final counterRef = _firestore.collection('counters').doc(counterName);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int lastNumber = 0;
      if (snapshot.exists) {
        lastNumber = (snapshot.data()?['lastNumber'] ?? 0) as int;
      }

      final nextNumber = lastNumber + 1;
      transaction.set(
        counterRef,
        {'lastNumber': nextNumber},
        SetOptions(merge: true),
      );

      final formattedNumber = nextNumber.toString().padLeft(6, '0');
      return '$prefix$formattedNumber';
    });
  }

  // 🔥 BARU: generator kode unik untuk pasien (anak), format PED-0001, dst.
  // Pakai pola yang SAMA dengan generateUserCode() di atas (Firestore
  // transaction) supaya dijamin atomik/tidak bentrok walau ada beberapa
  // parent yang submit profil di waktu yang nyaris bersamaan.
  Future<String> generatePatientCode() async {
    final counterRef = _firestore.collection('counters').doc('patient_counter');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int lastNumber = 0;
      if (snapshot.exists) {
        lastNumber = (snapshot.data()?['lastNumber'] ?? 0) as int;
      }

      final nextNumber = lastNumber + 1;
      transaction.set(
        counterRef,
        {'lastNumber': nextNumber},
        SetOptions(merge: true),
      );

      final formattedNumber = nextNumber.toString().padLeft(4, '0');
      return 'PED-$formattedNumber';
    });
  }
}