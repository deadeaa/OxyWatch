// services/auth_service.dart
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
      final userCode = await _codeGeneratorService.generateUserCode(role);
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

  // ==========================
  // LOGIN
  // ==========================

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

  // ==========================
  // LOGOUT
  // ==========================

  Future<void> logout() async {
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

  // ==========================
  // UPDATE USER DATA
  // ==========================

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
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