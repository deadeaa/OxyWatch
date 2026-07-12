import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../models/user_model.dart';
import '../config/app_colors.dart';
import '../widgets/oxywatch_logo.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLang = languageProvider.currentLanguage;
    final isId = currentLang == 'id';
    final isDoctor = widget.role == 'doctor';

    // 🔥 SEMUA TEKS PAKE currentLang
    final title = isId ? 'Daftar Akun' : 'Create Account';
    final subtitle = isId
        ? (isDoctor ? 'Dokter Press Healthcare' : 'OxyWatch')
        : (isDoctor ? 'Press Healthcare Doctor' : 'OxyWatch');
    final createAccount = isId ? 'Buat akun baru' : 'Create new account';
    final fullName = isId ? 'Nama Lengkap' : 'Full Name';
    final fullNameHint = isId ? 'Masukkan nama lengkap' : 'Enter full name';
    final emailLabel = isId ? 'Email' : 'Email';
    final emailHint = isId ? 'nama@email.com' : 'name@email.com';
    final doctorEmailHint = isId
        ? 'nama.dokter@presuhealthcare.doc.ac.id'
        : 'doctor.name@presuhealthcare.doc.ac.id';
    final passwordLabel = isId ? 'Password' : 'Password';
    final passwordHint = isId
        ? 'Masukkan password (min 6 karakter)'
        : 'Enter password (min 6 characters)';
    final confirmPassword = isId ? 'Konfirmasi Password' : 'Confirm Password';
    final confirmPasswordHint = isId ? 'Masukkan ulang password' : 'Re-enter password';
    final registerButton = isId ? 'Daftar' : 'Register';
    final alreadyHaveAccount = isId ? 'Sudah punya akun? Login' : 'Already have an account? Login';
    final nameRequired = isId ? 'Nama wajib diisi' : 'Name is required';
    final nameMin2 = isId ? 'Nama minimal 2 karakter' : 'Name must be at least 2 characters';
    final emailRequired = isId ? 'Email wajib diisi' : 'Email is required';
    final invalidEmail = isId ? 'Email tidak valid' : 'Invalid email';
    final emailMustUseDomain = isId
        ? 'Email harus menggunakan domain @presuhealthcare.doc.ac.id'
        : 'Email must use domain @presuhealthcare.doc.ac.id';
    final passwordRequired = isId ? 'Password wajib diisi' : 'Password is required';
    final passwordMin6 = isId ? 'Password minimal 6 karakter' : 'Password must be at least 6 characters';
    final confirmPasswordRequired = isId ? 'Konfirmasi password wajib diisi' : 'Confirm password is required';
    final passwordNotMatch = isId ? 'Password tidak cocok' : 'Passwords do not match';
    final registerAsDoctor = isId ? 'Daftar sebagai Dokter' : 'Register as Doctor';
    final registerAsParent = isId ? 'Daftar sebagai Orang Tua' : 'Register as Parent';

    // 🔥 Tujuan back button
    final backRoute = isDoctor ? '/doctor-login' : '/login';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Stack(
                children: [
                  // Back button - KIRI (kembali ke login yang sesuai)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        // 🔥 Kembali ke login parent atau doctor
                        Navigator.pushReplacementNamed(context, backRoute);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Language toggle - KANAN
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildLangButton('id', 'ID', currentLang, context),
                          _buildLangButton('en', 'EN', currentLang, context),
                        ],
                      ),
                    ),
                  ),
                  // Logo and title - CENTER
                  Center(
                    child: Column(
                      children: [
                        const OxyWatchLogo(size: 40, showPulse: false),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFFA9B7CC),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // White card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          createAccount,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDoctor
                                    ? Icons.medical_services_outlined
                                    : Icons.person_outline,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isDoctor ? registerAsDoctor : registerAsParent,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nama Lengkap
                        _buildTextField(
                          label: fullName,
                          hint: fullNameHint,
                          controller: _namaController,
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return nameRequired;
                            }
                            if (value.trim().length < 2) {
                              return nameMin2;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _buildTextField(
                          label: emailLabel,
                          hint: isDoctor ? doctorEmailHint : emailHint,
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return emailRequired;
                            }
                            if (!value.contains('@')) {
                              return invalidEmail;
                            }
                            if (isDoctor && !value.contains('@presuhealthcare.doc.ac.id')) {
                              return emailMustUseDomain;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        _buildTextField(
                          label: passwordLabel,
                          hint: passwordHint,
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return passwordRequired;
                            }
                            if (value.length < 6) {
                              return passwordMin6;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password
                        _buildTextField(
                          label: confirmPassword,
                          hint: confirmPasswordHint,
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return confirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return passwordNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              registerButton,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 🔥 Link "Sudah punya akun? Login" - ke login yang sesuai
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, backRoute);
                            },
                            child: Text(
                              alreadyHaveAccount,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF94A3B8),
              size: 16,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildLangButton(
      String code,
      String label,
      String currentLang,
      BuildContext context,
      ) {
    final isSelected = currentLang == code;
    final languageProvider = context.read<LanguageProvider>();
    final authProvider = context.read<AuthProvider>();

    return GestureDetector(
      onTap: () {
        languageProvider.setLanguage(code);
        authProvider.updateUserLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final role = widget.role == 'doctor' ? UserRole.doctor : UserRole.parent;

      final success = await authProvider.register(
        fullName: _namaController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: role,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Register berhasil! Silakan login'),
            backgroundColor: Colors.green,
          ),
        );

        await authProvider.logout();

        if (role == UserRole.doctor) {
          Navigator.pushReplacementNamed(context, '/doctor-login');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${authProvider.error ?? 'Register gagal'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}