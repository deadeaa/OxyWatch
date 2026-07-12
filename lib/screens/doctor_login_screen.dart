import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/register_screen.dart';

class DoctorLoginScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DoctorLoginScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _touched = false;
  String _emailError = '';

  static const String _domain = '@presuhealthcare.doc.ac.id';

  String _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!value.contains(_domain)) {
      return 'Email harus menggunakan domain $_domain';
    }
    return '';
  }

  void _handleEmailChange(String value) {
    setState(() {
      if (_touched) {
        _emailError = _validateEmail(value);
      }
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _touched = true;
      _emailError = _validateEmail(email);
    });

    if (_emailError.isNotEmpty) return;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/doctor');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLang = languageProvider.currentLanguage;
    final isId = currentLang == 'id';

    // 🔥 SEMUA TEKS PAKE currentLang
    final doctorLogin = isId ? 'Login Dokter' : 'Doctor Login';
    final doctorLoginSubtitle = isId ? 'Press Healthcare — OxyWatch Clinic' : 'Press Healthcare — OxyWatch Clinic';
    final institutionalEmail = isId ? 'Email Institusi' : 'Institutional Email';
    final institutionalEmailHint = isId
        ? 'nama.dokter@presuhealthcare.doc.ac.id'
        : 'doctor.name@presuhealthcare.doc.ac.id';
    final institutionalEmailNote = isId
        ? 'Gunakan email institusi @presuhealthcare.doc.ac.id'
        : 'Use institutional email @presuhealthcare.doc.ac.id';
    final emailRequired = isId ? 'Email wajib diisi' : 'Email is required';
    final emailMustUseDomain = isId
        ? 'Email harus menggunakan domain @presuhealthcare.doc.ac.id'
        : 'Email must use domain @presuhealthcare.doc.ac.id';
    final emailValid = isId ? 'Email valid' : 'Email valid';
    final passwordLabel = isId ? 'Password' : 'Password';
    final passwordHint = isId ? 'Masukkan kata sandi' : 'Enter password';
    final passwordRequired = isId ? 'Password wajib diisi' : 'Password is required';
    final passwordMin6 = isId ? 'Password minimal 6 karakter' : 'Password must be at least 6 characters';
    final forgotPasswordText = isId ? 'Lupa kata sandi?' : 'Forgot password?';
    final forgotPasswordComingSoon = isId
        ? 'Fitur lupa kata sandi segera hadir'
        : 'Forgot password feature coming soon';
    final loginAsDoctor = isId ? 'Masuk sebagai Dokter' : 'Login as Doctor';
    final contactIT = isId
        ? 'Hubungi IT Press Healthcare untuk akses akun dokter'
        : 'Contact IT Press Healthcare for doctor account access';
    final registerLink = isId
        ? 'Belum punya akun dokter? Daftar'
        : 'Don\'t have a doctor account? Register';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Stack(
                children: [
                  // Back button - KIRI (kembali ke role selection)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: widget.onBack,
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
                  // Center: Logo dan title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16233B),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF4FC3F7),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doctorLogin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorLoginSubtitle,
                          style: const TextStyle(
                            color: Color(0xFFA9B7CC),
                            fontSize: 11,
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
                        // Institutional note
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4FC3F7).withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4FC3F7),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  institutionalEmailNote,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1B3A5C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              institutionalEmail,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              onChanged: _handleEmailChange,
                              onTap: () {
                                if (!_touched) {
                                  setState(() => _touched = false);
                                }
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1B3A5C),
                              ),
                              decoration: InputDecoration(
                                hintText: institutionalEmailHint,
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: _emailError.isNotEmpty
                                    ? const Color(0xFFFFF5F5)
                                    : const Color(0xFFF8FAFF),
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
                                    color: Color(0xFF4FC3F7),
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
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return emailRequired;
                                }
                                if (!value.contains(_domain)) {
                                  return emailMustUseDomain;
                                }
                                return null;
                              },
                            ),
                            // Email validation feedback
                            if (_emailError.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _emailError,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (_touched &&
                                _emailController.text.isNotEmpty &&
                                _emailController.text.contains(_domain)) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF22C55E),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    emailValid,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF22C55E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              passwordLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onFieldSubmitted: (_) => _handleLogin(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1B3A5C),
                              ),
                              decoration: InputDecoration(
                                hintText: passwordHint,
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                ),
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
                                    color: Color(0xFF4FC3F7),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 16,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
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
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(forgotPasswordComingSoon),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: Text(
                                  forgotPasswordText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF4FC3F7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // CTA
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B3A5C),
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
                              loginAsDoctor,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            contactIT,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        // 🔥 LINK KE REGISTER DOCTOR
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(role: 'doctor'),
                                ),
                              );
                            },
                            child: Text(
                              registerLink,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4FC3F7),
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
}