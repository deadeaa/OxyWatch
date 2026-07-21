import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';
import 'code_generator_service.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CodeGeneratorService _codeGeneratorService = CodeGeneratorService();

  User? get currentUser => _auth.currentUser;

  // ==========================
  // REGISTER
  // ==========================

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      debugPrint("========== REGISTER START ==========");

      final credential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseAuthException(
          code: 'network-timeout',
          message:
          'Koneksi ke server timeout. Cek koneksi internet / jaringan kamu.',
        ),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.failure("Failed to create account.");
      }

      debugPrint("STEP 1 ✓ Firebase Auth Success");

      await firebaseUser.updateDisplayName(fullName);
      debugPrint("STEP 2 ✓ Display Name Updated");

      final userCode = await _codeGeneratorService.generateUserCode(role);
      debugPrint("STEP 3 ✓ User Code: $userCode");

      final user = UserModel(
        uid: firebaseUser.uid,
        userCode: userCode,
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      debugPrint("STEP 4 ✓ UserModel Created");

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toMap())
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseAuthException(
          code: 'network-timeout',
          message:
          'Akun berhasil dibuat, tapi gagal simpan data ke server. Cek koneksi internet dan coba login manual.',
        ),
      );
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

  // ==========================
  // LOGIN
  // ==========================

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("========== LOGIN START ==========");

      final credential = await _auth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseAuthException(
          code: 'network-timeout',
          message:
          'Koneksi ke server timeout. Cek koneksi internet / jaringan kamu.',
        ),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return AuthResult.failure("Failed to login.");
      }

      debugPrint("STEP 1 ✓ Firebase Auth Success");

      final snapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseAuthException(
          code: 'network-timeout',
          message:
          'Login berhasil, tapi gagal ambil data profil. Cek koneksi internet dan coba lagi.',
        ),
      );

      if (!snapshot.exists) {
        return AuthResult.failure("User data not found.");
      }

      final user = UserModel.fromMap(snapshot.data()!);
      debugPrint("STEP 2 ✓ Firestore Loaded: ${user.fullName}");

      // 🔥 BARU: tandai user ini online. Catatan jujur: ini BUKAN presence
      // real-time yang akurat (kalau app di-force-close/koneksi putus
      // mendadak, status ini akan nyangkut 'true'). Presence yang benar
      // butuh Firebase Realtime Database (onDisconnect()), di luar scope
      // sekarang. Ini cukup untuk kebutuhan "dokter lagi aktif atau tidak"
      // secara kasar.
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'isOnline': true,
      });

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

  // ==========================
  // LOGOUT
  // ==========================

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'isOnline': false,
        });
      } catch (e) {
        // Kalau update ini gagal (misal jaringan putus pas logout), jangan
        // sampai gagal logout-nya juga. Logout tetap harus jalan.
        debugPrint("Gagal set isOnline=false: $e");
      }
    }
    await _auth.signOut();
    debugPrint("Logout Success");
  }

  // ==========================
  // RESET PASSWORD
  // ==========================

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ==========================
  // GET USER DATA
  // ==========================

  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!snapshot.exists) return null;
      return UserModel.fromMap(snapshot.data()!);
    } catch (e) {
      debugPrint("Error getting user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataMap(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!snapshot.exists) return null;
      return snapshot.data();
    } catch (e) {
      debugPrint("Error getting user data map: $e");
      return null;
    }
  }

  // ==========================
  // UPDATE USER DATA
  // ==========================

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // ==========================
  // DELETE USER DATA
  // ==========================

  Future<void> deleteUserData(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
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
      case 'network-timeout':
        return e.message ?? 'Koneksi timeout. Cek jaringan internet kamu.';
      default:
        return e.message ?? 'Terjadi kesalahan.';
    }
  }
}