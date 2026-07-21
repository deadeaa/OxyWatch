import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/oxywatch_logo.dart';
import '../screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔥 FIX: cek dulu apakah masih ada halaman untuk di-pop.
  // Setelah logout, stack navigasi dikosongkan total (pushAndRemoveUntil
  // dengan predicate `(route) => false`), jadi LoginScreen jadi satu-satunya
  // halaman di stack. Kalau langsung Navigator.pop(context) tanpa cek,
  // hasilnya stack jadi benar-benar kosong -> layar hitam.
  // Solusinya: kalau tidak bisa pop, arahkan eksplisit ke role-selection.
  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/role-selection');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final user = authProvider.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (user?.role == UserRole.parent) {
          if (authProvider.isProfileCompleted) {
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/doctor');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed.'),
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

    // 🔥 LANGSUNG PAKE currentLang buat semua teks
    final isId = currentLang == 'id';

    // Text translations
    final welcomeBack = isId ? 'Selamat datang' : 'Welcome';
    final loginTitle = isId ? 'Masuk ke akun Anda' : 'Sign in to your account';
    final emailLabel = isId ? 'Email' : 'Email';
    final emailHint = isId ? 'nama@email.com' : 'name@email.com';
    final passwordLabel = isId ? 'Password' : 'Password';
    final passwordHint = isId ? 'Masukkan kata sandi' : 'Enter password';
    final forgotPassword = isId ? 'Lupa kata sandi?' : 'Forgot password?';
    final loginButton = isId ? 'Masuk' : 'Login';
    final registerLink = isId ? 'Belum punya akun? Daftar' : 'Don\'t have an account? Register';
    final emailRequired = isId ? 'Email wajib diisi' : 'Email is required';
    final invalidEmail = isId ? 'Email tidak valid' : 'Invalid email';
    final passwordRequired = isId ? 'Password wajib diisi' : 'Password is required';
    final passwordMin6 = isId ? 'Password minimal 6 karakter' : 'Password must be at least 6 characters';
    final forgotPasswordComingSoon = isId ? 'Fitur lupa kata sandi segera hadir' : 'Forgot password feature coming soon';

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
                  // Back button - KIRI (kembali ke role selection)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _handleBack(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.12),
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
                          welcomeBack,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'OxyWatch',
                          style: TextStyle(
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
                          loginTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emailLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                hintText: emailHint,
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
                                    color: AppColors.primaryLight,
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
                                if (!value.contains('@')) {
                                  return invalidEmail;
                                }
                                return null;
                              },
                            ),
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
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
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
                                    color: AppColors.primaryLight,
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
                                  forgotPassword,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
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
                              loginButton,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Register link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(role: 'parent'),
                                ),
                              );
                            },
                            child: Text(
                              registerLink,
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
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}