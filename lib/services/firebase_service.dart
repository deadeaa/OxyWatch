// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_result_model.dart';
import 'code_generator_service.dart';

class FirebaseService {
  FirebaseService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CodeGeneratorService _codeGenerator = CodeGeneratorService();

  // ==========================
  // AUTH
  // ==========================

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      debugPrint("========== REGISTER START ==========");

      // STEP 1: Create user di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.failure("Failed to create account.");
      }

      debugPrint("STEP 1 ✓ Firebase Auth Success");

      // STEP 2: Update display name
      await firebaseUser.updateDisplayName(fullName);
      debugPrint("STEP 2 ✓ Display Name Updated");

      // STEP 3: Generate user code
      final userCode = await _codeGenerator.generateUserCode(role);
      debugPrint("STEP 3 ✓ User Code: $userCode");

      // STEP 4: Create UserModel
      final user = UserModel(
        uid: firebaseUser.uid,
        userCode: userCode,
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      debugPrint("STEP 4 ✓ UserModel Created");

      // STEP 5: Save to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toMap());
      debugPrint("STEP 5 ✓ Firestore Saved");

      debugPrint("========== REGISTER SUCCESS ==========");

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      debugPrint("========== REGISTER ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return AuthResult.failure("Unexpected error: $e");
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("========== LOGIN START ==========");

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.failure("Failed to login.");
      }

      debugPrint("STEP 1 ✓ Firebase Auth Success");

      // Ambil data dari Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!snapshot.exists) {
        return AuthResult.failure("User data not found.");
      }

      final user = UserModel.fromMap(snapshot.data()!);
      debugPrint("STEP 2 ✓ Firestore Loaded: ${user.fullName}");

      debugPrint("========== LOGIN SUCCESS ==========");

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      debugPrint("========== LOGIN ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return AuthResult.failure("Unexpected error: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    debugPrint("Logout Success");
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  User? get currentUser => _auth.currentUser;

  // ==========================
  // FIRESTORE - PATIENT DATA
  // ==========================

  Future<void> savePatientData({
    required String userId,
    required String nama,
    required String usia,
    required String bb,
    required String tb,
    required String goldar,
    required List<String> riwayat,
    required bool alertSpO2,
    required bool alertHR,
  }) async {
    final patientId = 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 10)}';

    await _firestore.collection('patients').doc(patientId).set({
      'userId': userId,
      'nama': nama,
      'usia': usia,
      'bb': bb,
      'tb': tb,
      'goldar': goldar,
      'riwayat': riwayat,
      'alertSpO2': alertSpO2,
      'alertHR': alertHR,
      'patientId': patientId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update user dengan patientId
    await _firestore.collection('users').doc(userId).update({
      'patientId': patientId,
    });
  }

  Future<Map<String, dynamic>?> getPatientData(String patientId) async {
    final snapshot = await _firestore
        .collection('patients')
        .doc(patientId)
        .get();

    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  Future<void> updatePatientData(String patientId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('patients').doc(patientId).update(data);
  }

  // ==========================
  // FIRESTORE - VITAL SIGNS
  // ==========================

  Future<void> saveVitalSigns({
    required String patientId,
    required int spo2,
    required int heartRate,
    required String status,
  }) async {
    await _firestore.collection('vitals').add({
      'patientId': patientId,
      'spo2': spo2,
      'heartRate': heartRate,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamVitals(String patientId) {
    return _firestore
        .collection('vitals')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getVitalsHistory(
      String patientId, {
        int limit = 50,
      }) async {
    final snapshot = await _firestore
        .collection('vitals')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ==========================
  // FIRESTORE - NOTIFICATIONS
  // ==========================

  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ==========================
  // HELPER
  // ==========================

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'user-not-found':
        return 'Email tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return e.message ?? 'Terjadi kesalahan.';
    }
  }
}