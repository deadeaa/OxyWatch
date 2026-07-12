import 'user_model.dart';

class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  /// Factory untuk hasil sukses
  factory AuthResult.success(UserModel user) {
    return AuthResult(
      success: true,
      user: user,
    );
  }

  /// Factory untuk hasil gagal
  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}