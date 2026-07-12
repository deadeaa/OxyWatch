// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  parent,
  doctor,
}

class UserModel {
  final String uid;
  final String userCode;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.userCode,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userCode': userCode,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      userCode: map['userCode'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
      createdAt: _parseCreatedAt(map['createdAt']),
    );
  }

  static UserRole _parseRole(dynamic value) {
    switch (value) {
      case 'doctor':
        return UserRole.doctor;
      case 'parent':
      default:
        return UserRole.parent;
    }
  }

  /// Firestore bisa menyimpan createdAt sebagai Timestamp (kalau ditulis
  /// pakai FieldValue.serverTimestamp() / Timestamp.now()), tapi model ini
  /// awalnya menulis sebagai String (toIso8601String()). Handle keduanya
  /// supaya tidak error saat membaca data lama maupun baru.
  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}